module tower::difficulty {
  use std::string;

  struct Difficulty has store, copy, drop {
    name: string::String,
    options: u8,
    correct: u8,
    multiples: vector<u32>,
  }

  public fun new(name: vector<u8>, options: u8, correct: u8, multiples: vector<u32>): Difficulty {
    Difficulty {
      name: string::utf8(name),
      options: options,
      correct: correct,
      multiples: multiples,
    }
  }

  public fun difficulties(): vector<Difficulty> {
    let easy = new(b"easy", 4, 3, vector<u32>[126, 159, 201, 254, 321, 406, 514, 651, 824]);
    let medium = new(b"medium", 3, 2, vector<u32>[142, 202, 287, 408, 581, 827, 1178, 1678, 2391]);
    let hard = new(b"hard", 2, 1, vector<u32>[190, 361, 685, 1301, 2471, 4694, 8918, 16944, 32193]);
    let extreme = new(b"extreme", 3, 1, vector<u32>[285, 812, 2314, 6594, 18792, 53557]);
    let nightmare = new(b"nightmare", 4, 1, vector<u32>[380, 1444, 5487, 20850, 79230, 301074]);

    vector<Difficulty>[easy, medium, hard, extreme, nightmare]
  }
}