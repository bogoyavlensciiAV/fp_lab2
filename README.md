# lab2 on gleam⭐(Богоявленский Александр P3317)
## Вариант: sc-set

## Требования к разработанному ПО

### Функциональные требования
- добавление и удаление элементов;

- фильтрация;

- отображение (map);

- свертки (левая и правая);

- структура должна быть моноидом.

## Ключевые элементы реализации
Устройство
```gleam
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
```
Часть операций:
```gleam
pub fn new(hash: fn(k) -> Int, eq: fn(k, k) -> Bool, cmp: fn(k, k) -> Order) 
  -> SCSet(k)

pub fn insert(set: SCSet(k), value: k) -> SCSet(k)
pub fn delete(set: SCSet(k), value: k) -> SCSet(k)  
pub fn member(set: SCSet(k), value: k) -> Bool
pub fn union(a: SCSet(k), b: SCSet(k)) -> SCSet(k)
```
## Вывод
Реализовывать было прикольно, хотя узнал интересную особенность, из-за которой ненадолго встрял:
```gleam
  let a = True
  let b = True //Type mismatch
  (a && b) |> should.equal(True)
```
Из-за того что он принял эту передачу за функцию, он начинает ругаться

Всвязи с чем рабочей реализацией будет
```gleam
  let a = True
  let b = True
  let c = a && b
  c |> should.equal(True)

  //либо без пайпа

  let a = True
  let b = True
  should.equal(a && b,True)
```
