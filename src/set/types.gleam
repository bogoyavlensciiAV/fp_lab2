pub type Bucket(k) {
  Bucket(items: List(k))
}

pub opaque type Set(k) {
  Set(
    buckets: List(Bucket(k)),
    size: Int,
    capacity: Int,
    hasher: fn(k) -> Int,
    eq: fn(k, k) -> Bool,
  )
}

pub fn get_size(s: Set(k)) -> Int {
  s.size
}

pub fn get_capacity(s: Set(k)) -> Int {
  s.capacity
}

pub fn get_buckets(s: Set(k)) -> List(Bucket(k)) {
  s.buckets
}

pub fn get_hasher(s: Set(k)) -> fn(k) -> Int {
  s.hasher
}

pub fn get_eq(s: Set(k)) -> fn(k, k) -> Bool {
  s.eq
}

pub fn make(
  buckets: List(Bucket(k)),
  size: Int,
  capacity: Int,
  hasher: fn(k) -> Int,
  eq: fn(k, k) -> Bool,
) -> Set(k) {
  Set(buckets, size, capacity, hasher, eq)
}
