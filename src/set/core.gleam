import gleam/int
import gleam/list
import set/types.{type Bucket, type Set, Bucket}

const initial_capacity = 16

const load_factor = 0.75

pub fn new(hasher: fn(k) -> Int, eq: fn(k, k) -> Bool) -> Set(k) {
  let buckets = list.repeat(Bucket([]), initial_capacity)
  types.make(buckets, 0, initial_capacity, hasher, eq)
}

pub fn from_list(
  items: List(k),
  hasher: fn(k) -> Int,
  eq: fn(k, k) -> Bool,
) -> Set(k) {
  list.fold(items, new(hasher, eq), fn(acc, item) { insert(acc, item) })
}

pub fn insert(set: Set(k), key: k) -> Set(k) {
  let set = maybe_resize(set)
  insert_internal(set, key)
}

fn insert_internal(set: Set(k), key: k) -> Set(k) {
  let hasher = types.get_hasher(set)
  let eq = types.get_eq(set)
  let capacity = types.get_capacity(set)
  let hash = abs(hasher(key)) % capacity

  let #(new_buckets, was_new) =
    update_bucket_insert(types.get_buckets(set), hash, key, eq)

  let new_size = case was_new {
    True -> types.get_size(set) + 1
    False -> types.get_size(set)
  }

  types.make(new_buckets, new_size, capacity, hasher, eq)
}

pub fn member(set: Set(k), key: k) -> Bool {
  let hasher = types.get_hasher(set)
  let eq = types.get_eq(set)
  let capacity = types.get_capacity(set)
  let hash = abs(hasher(key)) % capacity

  case list_get(types.get_buckets(set), hash) {
    Error(_) -> False
    Ok(bucket) -> list.any(bucket.items, fn(x) { eq(x, key) })
  }
}

pub fn delete(set: Set(k), key: k) -> Set(k) {
  let hasher = types.get_hasher(set)
  let eq = types.get_eq(set)
  let capacity = types.get_capacity(set)
  let hash = abs(hasher(key)) % capacity

  let #(new_buckets, was_deleted) =
    update_bucket_delete(types.get_buckets(set), hash, key, eq)

  let new_size = case was_deleted {
    True -> types.get_size(set) - 1
    False -> types.get_size(set)
  }

  types.make(new_buckets, new_size, capacity, hasher, eq)
}

pub fn size(set: Set(k)) -> Int {
  types.get_size(set)
}

pub fn is_empty(set: Set(k)) -> Bool {
  types.get_size(set) == 0
}

pub fn to_list(set: Set(k)) -> List(k) {
  types.get_buckets(set)
  |> list.flat_map(fn(bucket) { bucket.items })
}

pub fn check_for_all(set: Set(k), f: fn(k) -> Bool) -> Bool {
  let buckets1 = types.get_buckets(set)
  list.all(buckets1, fn(bucket) { list.all(bucket.items, f) })
}

fn update_bucket_insert(
  buckets: List(Bucket(k)),
  index: Int,
  key: k,
  eq: fn(k, k) -> Bool,
) -> #(List(Bucket(k)), Bool) {
  let #(new_buckets, was_new) =
    list.index_fold(buckets, #([], False), fn(acc, bucket, i) {
      let #(acc_list, acc_flag) = acc
      case i == index {
        True -> {
          case list.any(bucket.items, fn(x) { eq(x, key) }) {
            True -> #(list.append(acc_list, [bucket]), acc_flag)
            False -> #(
              list.append(acc_list, [Bucket([key, ..bucket.items])]),
              True,
            )
          }
        }
        False -> #(list.append(acc_list, [bucket]), acc_flag)
      }
    })

  #(new_buckets, was_new)
}

fn update_bucket_delete(
  buckets: List(Bucket(k)),
  index: Int,
  key: k,
  eq: fn(k, k) -> Bool,
) -> #(List(Bucket(k)), Bool) {
  let #(new_buckets, was_deleted) =
    list.index_fold(buckets, #([], False), fn(acc, bucket, i) {
      let #(acc_list, acc_flag) = acc
      case i == index {
        True -> {
          let old_len = list.length(bucket.items)
          let new_items = list.filter(bucket.items, fn(x) { !eq(x, key) })
          let new_len = list.length(new_items)
          #(
            list.append(acc_list, [Bucket(new_items)]),
            acc_flag || old_len != new_len,
          )
        }
        False -> #(list.append(acc_list, [bucket]), acc_flag)
      }
    })

  #(new_buckets, was_deleted)
}

fn list_get(l: List(a), index: Int) -> Result(a, Nil) {
  case list.drop(l, index) {
    [first, ..] -> Ok(first)
    [] -> Error(Nil)
  }
}

fn maybe_resize(set: Set(k)) -> Set(k) {
  let size = types.get_size(set)
  let capacity = types.get_capacity(set)

  case int.to_float(size) >. int.to_float(capacity) *. load_factor {
    True -> resize(set, capacity * 2)
    False -> set
  }
}

fn resize(set: Set(k), new_capacity: Int) -> Set(k) {
  let hasher = types.get_hasher(set)
  let eq = types.get_eq(set)
  let new_buckets = list.repeat(Bucket([]), new_capacity)
  let new_set = types.make(new_buckets, 0, new_capacity, hasher, eq)

  list.fold(to_list(set), new_set, fn(acc, elem) { insert_internal(acc, elem) })
}

fn abs(n: Int) -> Int {
  case n < 0 {
    True -> -n
    False -> n
  }
}
