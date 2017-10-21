/*:
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
 
 ## `MutableCollection.swapAt` метод
 
 [SE-0173][SE-0173] представляет новый метод для того, чтобы поменять местами два элемента в коллекции. В противоположность существующей функции `swap(_:_:)`, метод `swapAt(_:_:)` берет индексы элементов, которые должны поменяться местами, а не сами элементы (с помощью `inout` аргументов).
 
 Причина появления этого дополнительного метода состоит в том, что функция `swap` с друмя inout` аргументами оказалась несовместимой с новыми исключающими правилами доступа к памяти, которые предложены в [SE-0176][SE-0176]. Существующая функция `swap(_:_:)` не будет больше работать с двуми элементами, которые меняются местами в одной и той же коллекцииw.
 
 [SE-0173]: https://github.com/apple/swift-evolution/blob/master/proposals/0173-swap-indices.md "Swift Evolution Proposal SE-0173: Add `MutableCollection.swapAt(_:_:)`"
 [SE-0176]: https://github.com/apple/swift-evolution/blob/master/proposals/0176-enforce-exclusive-access-to-memory.md "Swift Evolution Proposal SE-0176: Enforce Exclusive Access to Memory"
 */
var numbers = [1,2,3,4,5]

// Неверно в Swift 4:
// ошибка: overlapping accesses to var 'numbers', but modification requires exclusive access; consider calling MutableCollection.swapAt(_:_:)
//swap(&numbers[3], &numbers[4])

// Это новый способ выполнить то же самое:
numbers.swapAt(0,1)
numbers

/*:
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
 */
