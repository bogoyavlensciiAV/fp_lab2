import gleam/float
import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import qcheck
import set

pub fn main() {
  gleeunit.main()
}

fn int_hash(i: Int) -> Int {
  abs(i)
}

fn int_eq(a: Int, b: Int) -> Bool {
  a == b
}

fn float_hash(f: Float) -> Int {
  abs(float.round(f))
}

fn float_eq(a: Float, b: Float) -> Bool {
  a == b
}

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

fn gen_int() {
  qcheck.bounded_int(-1000, 1000)
}

fn gen_float() {
  qcheck.float()
}

fn gen_string() {
  qcheck.string()
}

fn gen_int_list() {
  qcheck.list_from(gen_int())
}

fn gen_string_list() {
  qcheck.list_from(gen_string())
}

// ===== INT ТЕСТЫ =====
pub fn property_insert_member_int_test() {
  use i <- qcheck.given(gen_int())
  let set0 = set.new(int_hash, int_eq)
  let set1 = set.insert(set0, i)
  should.be_true(set.member(set1, i))
}

pub fn property_insert_delete_not_member_int_test() {
  use i <- qcheck.given(gen_int())
  let set0 = set.new(int_hash, int_eq) |> set.insert(i) |> set.delete(i)
  should.be_false(set.member(set0, i))
}

pub fn property_no_duplicates_int_test() {
  use i <- qcheck.given(gen_int())
  let set0 =
    set.new(int_hash, int_eq)
    |> set.insert(i)
    |> set.insert(i)
    |> set.insert(i)
  should.equal(set.size(set0), 1)
}

pub fn property_size_matches_tolist_int_test() {
  use items <- qcheck.given(gen_int_list())
  let set0 = set.from_list(items, int_hash, int_eq)
  should.equal(set.size(set0), list.length(set.to_list(set0)))
}

// ===== FLOAT ТЕСТЫ =====
pub fn property_insert_member_float_test() {
  use f <- qcheck.given(gen_float())
  let set0 = set.new(float_hash, float_eq)
  let set1 = set.insert(set0, f)
  should.be_true(set.member(set1, f))
}

pub fn property_no_duplicates_float_test() {
  use f <- qcheck.given(gen_float())
  let set0 =
    set.new(float_hash, float_eq)
    |> set.insert(f)
    |> set.insert(f)
    |> set.insert(f)
  should.equal(set.size(set0), 1)
}

// ===== STRING ТЕСТЫ =====
pub fn property_insert_member_string_test() {
  use s <- qcheck.given(gen_string())
  let set0 = set.new(string_hash, str_eq)
  let set1 = set.insert(set0, s)
  should.be_true(set.member(set1, s))
}

pub fn property_insert_delete_not_member_string_test() {
  use s <- qcheck.given(gen_string())
  let set0 = set.new(string_hash, str_eq) |> set.insert(s) |> set.delete(s)
  should.be_false(set.member(set0, s))
}

pub fn property_no_duplicates_string_test() {
  use s <- qcheck.given(gen_string())
  let set0 =
    set.new(string_hash, str_eq)
    |> set.insert(s)
    |> set.insert(s)
    |> set.insert(s)
  should.equal(set.size(set0), 1)
}

pub fn property_size_matches_tolist_string_test() {
  use items <- qcheck.given(gen_string_list())
  let set0 = set.from_list(items, string_hash, str_eq)
  should.equal(set.size(set0), list.length(set.to_list(set0)))
}

pub fn property_filter_preserves_predicate_string_test() {
  let predicate = fn(s: String) { string.length(s) > 2 }
  use items <- qcheck.given(gen_string_list())
  let set0 = set.from_list(items, string_hash, str_eq)
  let filtered = set.filter(set0, predicate)
  let all_satisfy =
    set.fold_left(filtered, True, fn(acc, item) {
      case acc {
        False -> False
        True -> predicate(item)
      }
    })
  should.be_true(all_satisfy)
}
