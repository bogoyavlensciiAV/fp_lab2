import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import set

pub fn main() {
  gleeunit.main()
}

// вспомогательные штуки

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

// проверка базовых операций

pub fn insert_and_member_test() {
  let s =
    set.new(string_hash, str_eq)
    |> set.insert("a")
    |> set.insert("b")
    |> set.insert("c")

  set.member(s, "a") |> should.equal(True)
  set.member(s, "b") |> should.equal(True)
  set.member(s, "c") |> should.equal(True)
  set.member(s, "d") |> should.equal(False)
}

pub fn delete_test() {
  let s =
    set.new(string_hash, str_eq)
    |> set.insert("a")
    |> set.insert("b")
    |> set.delete("a")

  set.member(s, "a") |> should.equal(False)
  set.member(s, "b") |> should.equal(True)
  set.size(s) |> should.equal(1)
}

pub fn no_duplicates_test() {
  let s =
    set.new(string_hash, str_eq)
    |> set.insert("a")
    |> set.insert("a")
    |> set.insert("a")

  set.size(s) |> should.equal(1)
}

pub fn empty_set_test() {
  let s = set.empty(string_hash, str_eq)

  set.is_empty(s) |> should.equal(True)
  set.size(s) |> should.equal(0)
}

// filter / map / fold 

pub fn filter_test() {
  let s = set.from_list(["apple", "ab", "banana"], string_hash, str_eq)
  let filtered = set.filter(s, fn(x) { string.length(x) > 3 })

  set.member(filtered, "apple") |> should.equal(True)
  set.member(filtered, "banana") |> should.equal(True)
  set.member(filtered, "ab") |> should.equal(False)
}

pub fn map_test() {
  let s = set.from_list(["a", "b"], string_hash, str_eq)
  let mapped = set.map(s, string.uppercase, string_hash, str_eq)

  set.member(mapped, "A") |> should.equal(True)
  set.member(mapped, "B") |> should.equal(True)
  set.member(mapped, "a") |> should.equal(False)
}

pub fn fold_left_count_test() {
  let s = set.from_list(["a", "b", "c"], string_hash, str_eq)
  let count = set.fold_left(s, 0, fn(acc, _x) { acc + 1 })

  count |> should.equal(3)
}

pub fn fold_right_count_test() {
  let s = set.from_list(["a", "b", "c"], string_hash, str_eq)
  let count = set.fold_right(s, 0, fn(acc, _x) { acc + 1 })

  count |> should.equal(3)
}

// операции множеств

pub fn union_test() {
  let s1 = set.from_list(["a", "b"], string_hash, str_eq)
  let s2 = set.from_list(["b", "c"], string_hash, str_eq)
  let r = set.union(s1, s2)

  set.size(r) |> should.equal(3)
  set.member(r, "a") |> should.equal(True)
  set.member(r, "b") |> should.equal(True)
  set.member(r, "c") |> should.equal(True)
}

pub fn intersection_test() {
  let s1 = set.from_list(["a", "b", "c"], string_hash, str_eq)
  let s2 = set.from_list(["b", "c", "d"], string_hash, str_eq)
  let r = set.intersection(s1, s2)

  set.size(r) |> should.equal(2)
  set.member(r, "b") |> should.equal(True)
  set.member(r, "c") |> should.equal(True)
  set.member(r, "a") |> should.equal(False)
}

pub fn difference_test() {
  let s1 = set.from_list(["a", "b", "c"], string_hash, str_eq)
  let s2 = set.from_list(["b", "c"], string_hash, str_eq)
  let r = set.difference(s1, s2)

  set.size(r) |> should.equal(1)
  set.member(r, "a") |> should.equal(True)
  set.member(r, "b") |> should.equal(False)
}

// equals / subset

pub fn equals_test() {
  let s1 = set.from_list(["a", "b"], string_hash, str_eq)
  let s2 = set.from_list(["b", "a"], string_hash, str_eq)
  let s3 = set.from_list(["a", "c"], string_hash, str_eq)

  set.equals(s1, s2) |> should.equal(True)
  set.equals(s1, s3) |> should.equal(False)
}

pub fn subset_test() {
  let s1 = set.from_list(["a", "b"], string_hash, str_eq)
  let s2 = set.from_list(["a", "b", "c"], string_hash, str_eq)
  let s3 = set.from_list(["a", "d"], string_hash, str_eq)

  set.is_subset(s1, s2) |> should.equal(True)
  set.is_subset(s2, s1) |> should.equal(False)
  set.is_subset(s3, s2) |> should.equal(False)
}

// Свойства моноида (unit-тесты)

pub fn monoid_left_identity_test() {
  let s = set.from_list(["a", "b"], string_hash, str_eq)
  let e = set.empty(string_hash, str_eq)

  set.union(e, s)
  |> set.equals(s)
  |> should.equal(True)
}

pub fn monoid_right_identity_test() {
  let s = set.from_list(["a", "b"], string_hash, str_eq)
  let e = set.empty(string_hash, str_eq)

  set.union(s, e)
  |> set.equals(s)
  |> should.equal(True)
}

pub fn monoid_associativity_test() {
  let a = set.from_list(["a"], string_hash, str_eq)
  let b = set.from_list(["b"], string_hash, str_eq)
  let c = set.from_list(["c"], string_hash, str_eq)

  let left = set.union(set.union(a, b), c)
  let right = set.union(a, set.union(b, c))

  set.equals(left, right) |> should.equal(True)
}
