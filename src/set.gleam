import gleam/int
import gleam/io
import gleam/list
import gleam/string
import set/compare
import set/core
import set/higher_order
import set/monoid
import set/types

pub type Set(k) =
  types.Set(k)

pub fn new(hasher: fn(k) -> Int, eq: fn(k, k) -> Bool) -> Set(k) {
  core.new(hasher, eq)
}

pub fn from_list(
  items: List(k),
  hasher: fn(k) -> Int,
  eq: fn(k, k) -> Bool,
) -> Set(k) {
  core.from_list(items, hasher, eq)
}

pub fn insert(set: Set(k), item: k) -> Set(k) {
  core.insert(set, item)
}

pub fn delete(set: Set(k), item: k) -> Set(k) {
  core.delete(set, item)
}

pub fn member(set: Set(k), item: k) -> Bool {
  core.member(set, item)
}

pub fn size(set: Set(k)) -> Int {
  core.size(set)
}

pub fn is_empty(set: Set(k)) -> Bool {
  core.is_empty(set)
}

pub fn to_list(set: Set(k)) -> List(k) {
  core.to_list(set)
}

pub fn filter(set: Set(k), predicate: fn(k) -> Bool) -> Set(k) {
  higher_order.filter(set, predicate)
}

pub fn map(
  set: Set(k),
  f: fn(k) -> a,
  hasher: fn(a) -> Int,
  eq: fn(a, a) -> Bool,
) -> Set(a) {
  higher_order.map(set, f, hasher, eq)
}

pub fn fold_left(set: Set(k), initial: acc, f: fn(acc, k) -> acc) -> acc {
  higher_order.fold_left(set, initial, f)
}

pub fn fold_right(set: Set(k), initial: acc, f: fn(acc, k) -> acc) -> acc {
  higher_order.fold_right(set, initial, f)
}

pub fn empty(hasher: fn(k) -> Int, eq: fn(k, k) -> Bool) -> Set(k) {
  monoid.empty(hasher, eq)
}

pub fn union(left: Set(k), right: Set(k)) -> Set(k) {
  monoid.union(left, right)
}

pub fn intersection(left: Set(k), right: Set(k)) -> Set(k) {
  monoid.intersection(left, right)
}

pub fn difference(left: Set(k), right: Set(k)) -> Set(k) {
  monoid.difference(left, right)
}

pub fn equals(s1: Set(k), s2: Set(k)) -> Bool {
  compare.equals(s1, s2)
}

pub fn is_subset(s1: Set(k), s2: Set(k)) -> Bool {
  compare.is_subset(s1, s2)
}

pub fn main() {
  io.println("=== Separate Chaining Set Demo ===\n")

  let hasher = string_hash
  let eq = fn(a, b) { a == b }

  io.println("1. Создание и добавление элементов:")
  let set1 =
    new(hasher, eq)
    |> insert("apple")
    |> insert("banana")
    |> insert("cherry")
    |> insert("apple")

  print_set(set1, "set1")
  io.println("  size: " <> int.to_string(size(set1)))
  io.println("  member('apple'): " <> bool_to_string(member(set1, "apple")))
  io.println("  member('grape'): " <> bool_to_string(member(set1, "grape")))
  io.println("")

  io.println("2. Удаление элемента 'banana':")
  let set2 = delete(set1, "banana")
  print_set(set2, "set2")
  io.println("")

  io.println("3. Filter (длина > 5):")
  let filtered = filter(set1, fn(s) { string.length(s) > 5 })
  print_set(filtered, "filtered")
  io.println("")

  io.println("4. Map (uppercase):")
  let uppercased = map(set1, string.uppercase, string_hash, fn(a, b) { a == b })
  print_set(uppercased, "uppercased")
  io.println("")

  io.println("5. Fold left (concat):")
  let concat = fold_left(set1, "", fn(acc, s) { acc <> s <> " " })
  io.println("  result: \"" <> concat <> "\"")
  io.println("")

  io.println("6. Union:")
  let set_a = from_list(["x", "y"], hasher, eq)
  let set_b = from_list(["y", "z"], hasher, eq)
  print_set(set_a, "set_a")
  print_set(set_b, "set_b")
  let unioned = union(set_a, set_b)
  print_set(unioned, "union")
  io.println("")

  io.println("7. Intersection:")
  let intersected = intersection(set_a, set_b)
  print_set(intersected, "intersection")
  io.println("")

  io.println("8. Свойства моноида:")
  let empty_set = empty(hasher, eq)
  io.println(
    "  Left identity: "
    <> bool_to_string(equals(union(empty_set, set_a), set_a)),
  )
  io.println(
    "  Right identity: "
    <> bool_to_string(equals(union(set_a, empty_set), set_a)),
  )

  let set_c = from_list(["w"], hasher, eq)
  let left_assoc = union(union(set_a, set_b), set_c)
  let right_assoc = union(set_a, union(set_b, set_c))
  io.println(
    "  Associativity: " <> bool_to_string(equals(left_assoc, right_assoc)),
  )

  io.println("\n=== Demo Complete ===")
}

fn string_hash(s: String) -> Int {
  string.to_utf_codepoints(s)
  |> list.fold(0, fn(acc, cp) {
    abs(acc * 31 + string.utf_codepoint_to_int(cp))
  })
}

fn abs(n: Int) -> Int {
  case n < 0 {
    True -> -n
    False -> n
  }
}

fn print_set(set: Set(String), name: String) -> Nil {
  let items = to_list(set)
  io.println("  " <> name <> " = {" <> string.join(items, ", ") <> "}")
}

fn bool_to_string(b: Bool) -> String {
  case b {
    True -> "True"
    False -> "False"
  }
}
