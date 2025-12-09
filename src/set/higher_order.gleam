import gleam/list
import set/core
import set/types.{type Set}

pub fn filter(set: Set(k), predicate: fn(k) -> Bool) -> Set(k) {
  let items = core.to_list(set)
  let filtered = list.filter(items, predicate)
  core.from_list(filtered, types.get_hasher(set), types.get_eq(set))
}

pub fn map(
  set: Set(k),
  f: fn(k) -> a,
  new_hasher: fn(a) -> Int,
  new_eq: fn(a, a) -> Bool,
) -> Set(a) {
  let items = core.to_list(set)
  let mapped = list.map(items, f)
  core.from_list(mapped, new_hasher, new_eq)
}

pub fn fold_left(set: Set(k), initial: acc, f: fn(acc, k) -> acc) -> acc {
  let items = core.to_list(set)
  list.fold(items, initial, f)
}

pub fn fold_right(set: Set(k), initial: acc, f: fn(acc, k) -> acc) -> acc {
  let items = core.to_list(set)
  list.fold_right(items, initial, f)
}
