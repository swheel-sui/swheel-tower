module tower::game {
  use std::vector;

  use sui::object::{Self, UID};
  use sui::transfer;
  use sui::balance::{Self, Balance};
  use sui::tx_context::{Self, TxContext};
  use sui::types;
  use sui::coin::{Self, TreasuryCap};

  use tower::difficulty::Difficulty;
  use swheel::swheel::SWHEEL;

  friend tower::tower;

  const VERSION: u64 = 1;

  const ENotOneTimeWitness: u64 = 0;
  const ENeedUpgrade: u64 = 1;
  const ENotUpgrade: u64 = 2;

  struct Game<phantom T> has key {
    id: UID,
    version: u64,
    min_bet: u64,
    max_bet: u64,
    difficulties: vector<Difficulty>,
    balance: Balance<T>,
    reward: Balance<SWHEEL>,
    reward_ratio: u64,
  }

  struct GameOwnerCapability<phantom T> has key, store {
    id: UID,
  }

  public fun new<T, W: drop>(witness: W, min_bet: u64, max_bet: u64, 
    difficulties: vector<Difficulty>, reward_ratio: u64, ctx: &mut TxContext): GameOwnerCapability<T> {
    assert!(types::is_one_time_witness(&witness), ENotOneTimeWitness);

    let game = Game<T> {
      id: object::new(ctx),
      version: VERSION,
      min_bet: min_bet,
      max_bet: max_bet,
      difficulties: difficulties,
      balance: balance::zero<T>(),
      reward: balance::zero<SWHEEL>(),
      reward_ratio,
    };

    transfer::share_object(game);

    GameOwnerCapability<T> {
      id: object::new(ctx),
    }
  }

  fun check_version<T>(game: &Game<T>) {
    assert!(game.version == VERSION, ENeedUpgrade);
  }

  entry fun migrate<T>(_owner_cap: &GameOwnerCapability<T>, game: &mut Game<T>) {
    assert!(game.version < VERSION, ENotUpgrade);
    game.version = VERSION;
  }

  public entry fun inject<T>(game: &mut Game<T>, coin: coin::Coin<T>) {
    check_version(game);
    coin::put(&mut game.balance, coin);
  }

  public entry fun withdraw<T>(_owner_cap: &GameOwnerCapability<T>, game: &mut Game<T>, amount: u64, recipient: address, ctx: &mut TxContext) {
    check_version(game);
    let coin = coin::take(&mut game.balance, amount, ctx);
    transfer::public_transfer(coin, recipient);
  }

  public entry fun mint_reward<T>(treasury_cap: &mut TreasuryCap<SWHEEL>, amount: u64, game: &mut Game<T>, ctx: &mut TxContext) {
    check_version(game);
    let coin = coin::mint(treasury_cap, amount, ctx);
    coin::put(&mut game.reward, coin);
  }

  public(friend) fun reward_value<T>(game: &Game<T>, bet: u64): u64 {
    check_version(game);

    if (game.reward_ratio == 0 || bet == 0) return 0;

    let reward = bet * game.reward_ratio / 1_000_000_000;
    if (reward > balance::value(&game.reward)) {
      balance::value(&game.reward)
    } else {
      reward
    }
  }

  public(friend) fun send_reward<T>(game: &mut Game<T>, reward: u64, ctx: &mut TxContext) {
    check_version(game);

    if (reward == 0) return;

    let coin = coin::take(&mut game.reward, reward, ctx);
    transfer::public_transfer(coin, tx_context::sender(ctx));
  }

  public fun difficulty<T>(game: &Game<T>, level: u64): Difficulty {
    *vector::borrow<Difficulty>(&game.difficulties, level)
  }

  public fun min_bet<T>(game: &Game<T>): u64 {
    game.min_bet
  }

  public fun max_bet<T>(game: &Game<T>): u64 {
    game.max_bet
  }

  public(friend) fun incr_balance<T>(game: &mut Game<T>, balance: Balance<T>) {
    check_version(game);
    balance::join(&mut game.balance, balance);
  }

  public(friend) fun send_bonus<T>(game: &mut Game<T>, bonus: u64, ctx: &mut TxContext) {
    check_version(game);
    
    if (bonus == 0) return;

    let coin = coin::take(&mut game.balance, bonus, ctx);
    transfer::public_transfer(coin, tx_context::sender(ctx));
  }
}