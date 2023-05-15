module tower::state {
  use sui::object::{Self, UID};
  use sui::tx_context::TxContext;
  use sui::transfer;

  use tower::difficulty::Difficulty;
  use tower::game::{Self, Game};

  use swheel::randomness::Randomness;

  friend tower::tower;
  
  struct GameState<phantom T> has key, store {
    id: UID,
    difficulty: Difficulty,
    bet: u64,
    reward: u64,
    randomness: Randomness,
  }

  public fun new<T>(game: &Game<T>, level: u64, bet: u64, reward: u64, randomness: Randomness, ctx: &mut TxContext): GameState<T> {
    GameState {
      id: object::new(ctx),
      difficulty: game::difficulty(game, level),
      bet: bet,
      reward: reward,
      randomness: randomness,
    }
  }

  public fun transfer<T>(state: GameState<T>, recipient: address) {
    transfer::transfer(state, recipient);
  }

  public(friend) fun delete<T>(state: GameState<T>): Randomness {
    let GameState<T> { id, randomness, reward: _, bet: _, difficulty: _, } = state;
    object::delete(id);
    randomness
  }

  public fun difficulty<T>(state: &GameState<T>): Difficulty {
    state.difficulty
  }

  public fun bet<T>(state: &GameState<T>): u64 {
    state.bet
  }
}