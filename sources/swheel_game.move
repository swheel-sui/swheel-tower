module tower::swheel_game {
  use sui::tx_context::{Self, TxContext};
  use sui::transfer;

  use tower::game;
  use tower::difficulty;

  use swheel::swheel::SWHEEL;

  // 1 SWHEEL
  const MIN_BET: u64 = 1_000_000_000;
  // 1000 SWHEEL
  const MAX_BET: u64 = 1_000_000_000_000;
  // reward ratio 0
  const REWARD_RATIO: u64 = 0;

  struct SWHEEL_GAME has drop {}

  fun init(witness: SWHEEL_GAME, ctx: &mut TxContext) {
    let owner_cap = game::new<SWHEEL, SWHEEL_GAME>(witness, MIN_BET, MAX_BET, 
      difficulty::difficulties(), REWARD_RATIO, ctx);
    transfer::public_transfer(owner_cap, tx_context::sender(ctx));
  }

  #[test]
  fun test_init() {
    use sui::test_scenario;
    use tower::game::{Self, Game};

    let admin = @0xCAFE;
    let scenario_val = test_scenario::begin(admin);
    let scenario = &mut scenario_val;
    {
      init(SWHEEL_GAME {}, test_scenario::ctx(scenario));
    };

    test_scenario::next_tx(scenario, admin);
    {
      let game = test_scenario::take_shared<Game<SWHEEL>>(scenario);
      assert!(game::min_bet(&game) == MIN_BET && game::max_bet(&game) == MAX_BET, 0);
      test_scenario::return_shared(game);
    };

    test_scenario::end(scenario_val);
  }
}