import gleam/int
import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import set

pub fn main() {
  gleeunit.main()
}

// Вспомогательные штуки

fn string_hash(s: String) -> Int {
  string.to_utf_codepoints(s)
  |> list.fold(0, fn(acc, cp) {
    abs(acc * 31 + string.utf_codepoint_to_int(cp))
  })
}

fn str_eq(a: String, b: String) -> Bool {
  a == b
}

fn abs(n: Int) -> Int {
  case n < 0 {
    True -> -n
    False -> n
  }
}

// "случайная" строка длиной 1–10 из фиксированного алфавита
fn random_string() -> String {
  let alphabet = ["a", "b", "c", "x", "y", "z", "f"]
  let len = 1 + int.random(10)
  // 1..10

  list.range(0, len - 1)
  |> list.map(fn(_) {
    let idx = int.random(list.length(alphabet))
    case list.drop(alphabet, idx) {
      [h, ..] -> h
      [] -> "a"
    }
  })
  |> string.concat
}

// случайный список строк длиной 0–20
fn random_string_list() -> List(String) {
  let len = int.random(21)
  // 0..20
  list.range(0, len - 1)
  |> list.map(fn(_) { random_string() })
}

// Запускаем свойство n раз на новых случайных данных
fn run_bool_property_n_times(n: Int, prop: fn() -> Bool) -> Bool {
  list.range(0, n - 1)
  |> list.all(fn(_) { prop() })
}

// Проверка свойств

// insert(x) -> member(x)
pub fn property_insert_member_roundtrip_test() {
  let prop = fn() {
    let s = random_string()
    let s0 = set.new(string_hash, str_eq)
    let s1 = set.insert(s0, s)
    set.member(s1, s)
  }

  run_bool_property_n_times(100, prop) |> should.equal(True)
}

// insert(x) |> delete(x) -> !member(x)
pub fn property_insert_delete_not_member_test() {
  let prop = fn() {
    let s = random_string()
    let s0 =
      set.new(string_hash, str_eq)
      |> set.insert(s)
      |> set.delete(s)

    !set.member(s0, s)
  }

  run_bool_property_n_times(100, prop) |> should.equal(True)
}

// insert(x) много раз -> size == 1
pub fn property_no_duplicates_test() {
  let prop = fn() {
    let s = random_string()
    let s0 =
      set.new(string_hash, str_eq)
      |> set.insert(s)
      |> set.insert(s)
      |> set.insert(s)

    set.size(s0) == 1
  }

  run_bool_property_n_times(100, prop) |> should.equal(True)
}

// size == length(to_list)
pub fn property_size_matches_tolist_test() {
  let prop = fn() {
    let items = random_string_list()
    let s0 = set.from_list(items, string_hash, str_eq)
    set.size(s0) == list.length(set.to_list(s0))
  }

  run_bool_property_n_times(100, prop) |> should.equal(True)
}

// filter сохраняет предикат
pub fn property_filter_preserves_predicate_test() {
  let predicate = fn(s: String) { string.length(s) > 2 }

  let prop = fn() {
    let items = random_string_list()
    let s0 = set.from_list(items, string_hash, str_eq)
    let filtered = set.filter(s0, predicate)

    set.fold_left(filtered, True, fn(acc, item) {
      case acc {
        False -> False
        True -> predicate(item)
      }
    })
  }

  run_bool_property_n_times(100, prop) |> should.equal(True)
}

// filter не увеличивает размер
pub fn property_filter_size_less_equal_test() {
  let prop = fn() {
    let items = random_string_list()
    let s0 = set.from_list(items, string_hash, str_eq)
    let filtered = set.filter(s0, fn(x) { string.length(x) > 1 })

    set.size(filtered) <= set.size(s0)
  }

  run_bool_property_n_times(100, prop) |> should.equal(True)
}

// union коммутативен
pub fn property_union_commutative_test() {
  let prop = fn() {
    let s1 = set.from_list(random_string_list(), string_hash, str_eq)
    let s2 = set.from_list(random_string_list(), string_hash, str_eq)

    let u1 = set.union(s1, s2)
    let u2 = set.union(s2, s1)

    set.equals(u1, u2)
  }

  run_bool_property_n_times(100, prop) |> should.equal(True)
}

// union содержит все элементы
pub fn property_union_contains_all_test() {
  let prop = fn() {
    let s1 = set.from_list(random_string_list(), string_hash, str_eq)
    let s2 = set.from_list(random_string_list(), string_hash, str_eq)
    let result = set.union(s1, s2)

    let all_from_s1 =
      set.fold_left(s1, True, fn(acc, item) {
        case acc {
          False -> False
          True -> set.member(result, item)
        }
      })

    let all_from_s2 =
      set.fold_left(s2, True, fn(acc, item) {
        case acc {
          False -> False
          True -> set.member(result, item)
        }
      })

    all_from_s1 && all_from_s2
  }

  run_bool_property_n_times(100, prop) |> should.equal(True)
}

// empty ∪ s = s
pub fn property_monoid_left_identity_multiple_test() {
  let prop = fn() {
    let empty = set.empty(string_hash, str_eq)
    let s0 = set.from_list(random_string_list(), string_hash, str_eq)
    let result = set.union(empty, s0)
    set.equals(result, s0)
  }

  run_bool_property_n_times(100, prop) |> should.equal(True)
}

// s ∪ empty = s
pub fn property_monoid_right_identity_multiple_test() {
  let prop = fn() {
    let empty = set.empty(string_hash, str_eq)
    let s0 = set.from_list(random_string_list(), string_hash, str_eq)
    let result = set.union(s0, empty)
    set.equals(result, s0)
  }

  run_bool_property_n_times(100, prop) |> should.equal(True)
}

// (a ∪ b) ∪ c = a ∪ (b ∪ c)
pub fn property_monoid_associativity_multiple_test() {
  let prop = fn() {
    let a = set.from_list(random_string_list(), string_hash, str_eq)
    let b = set.from_list(random_string_list(), string_hash, str_eq)
    let c = set.from_list(random_string_list(), string_hash, str_eq)

    let left = set.union(set.union(a, b), c)
    let right = set.union(a, set.union(b, c))

    set.equals(left, right)
  }

  run_bool_property_n_times(100, prop) |> should.equal(True)
}

// equals рефлексивен
pub fn property_equals_reflexive_test() {
  let prop = fn() {
    let s0 = set.from_list(random_string_list(), string_hash, str_eq)
    set.equals(s0, s0)
  }

  run_bool_property_n_times(100, prop) |> should.equal(True)
}

// equals симметричен
pub fn property_equals_symmetric_test() {
  let prop = fn() {
    let items = random_string_list()
    let s1 = set.from_list(items, string_hash, str_eq)
    let s2 = set.from_list(items, string_hash, str_eq)

    let forward = set.equals(s1, s2)
    let backward = set.equals(s2, s1)

    forward == backward
  }

  run_bool_property_n_times(100, prop) |> should.equal(True)
}
