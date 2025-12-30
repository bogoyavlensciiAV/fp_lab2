import set/core
import set/types.{type Set}

pub fn equals(s1: Set(k), s2: Set(k)) -> Bool {
  core.size(s1) == core.size(s2) && is_subset(s1, s2)
}

pub fn is_subset(s1: Set(k), s2: Set(k)) -> Bool {
  core.check_for_all(s1, fn(x) { core.member(s2, x) })
}
