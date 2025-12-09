import gleam/list
import set/core
import set/higher_order
import set/types.{type Set}

pub fn empty(hasher: fn(k) -> Int, eq: fn(k, k) -> Bool) -> Set(k) {
  core.new(hasher, eq)
}

pub fn union(left: Set(k), right: Set(k)) -> Set(k) {
  higher_order.fold_left(right, left, fn(acc, elem) { core.insert(acc, elem) })
}

pub fn concat(
  sets: List(Set(k)),
  hasher: fn(k) -> Int,
  eq: fn(k, k) -> Bool,
) -> Set(k) {
  list.fold(sets, empty(hasher, eq), union)
}

pub fn intersection(left: Set(k), right: Set(k)) -> Set(k) {
  higher_order.filter(left, fn(elem) { core.member(right, elem) })
}

pub fn difference(left: Set(k), right: Set(k)) -> Set(k) {
  higher_order.filter(left, fn(elem) { !core.member(right, elem) })
}
