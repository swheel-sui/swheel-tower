module tower::sui_game {
  use sui::tx_context::{Self, TxContext};
  use sui::sui::SUI;
  use sui::transfer;

  use tower::game;
  use tower::difficulty;

  // 0.1 SUI
  const MIN_BET: u64 = 100_000_000;
  // 10 SUI
  const MAX_BET: u64 = 10_000_000_000;
  // reward ratio 1:1
  const REWARD_RATIO: u64 = 1_000_000_000;

  struct SUI_GAME has drop {}

  fun init(witness: SUI_GAME, ctx: &mut TxContext) {
    let owner_cap = game::new<SUI, SUI_GAME>(witness, MIN_BET, MAX_BET, 
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
      init(SUI_GAME {}, test_scenario::ctx(scenario));
    };

    test_scenario::next_tx(scenario, admin);
    {
      let game = test_scenario::take_shared<Game<SUI>>(scenario);
      assert!(game::min_bet(&game) == MIN_BET && game::max_bet(&game) == MAX_BET, 0);
      test_scenario::return_shared(game);
    };

    test_scenario::end(scenario_val);
  }
}