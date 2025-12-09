import set/core
import set/higher_order
import set/types.{type Set}

pub fn equals(s1: Set(k), s2: Set(k)) -> Bool {
  case core.size(s1) == core.size(s2) {
    False -> False
    True -> {
      higher_order.fold_left(s1, True, fn(acc, elem) {
        case acc {
          False -> False
          True -> core.member(s2, elem)
        }
      })
    }
  }
}

pub fn is_subset(s1: Set(k), s2: Set(k)) -> Bool {
  higher_order.fold_left(s1, True, fn(acc, elem) {
    case acc {
      False -> False
      True -> core.member(s2, elem)
    }
  })
}
