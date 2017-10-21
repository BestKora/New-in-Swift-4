/*:
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous)
 
 ## Private декларирование является "видимым" в расширениях `extensions` того же самого файла
 
 [SE-0169][SE-0169] изменяет правила доступа таким образом, что `private` декларирования также становятся "видимыми" внутри расширений `extensions` родительского типа  _в том же самом файле_. Это делает возможным разделение определения типа в многочисленных расширениях `extensions` и позволяет использовать `private` для действительно "private" элементов, уменьшая необходимость привлечения ключевого слова `fileprivate`.
 
 [SE-0169]: https://github.com/apple/swift-evolution/blob/master/proposals/0169-improve-interaction-between-private-declarations-and-extensions.md "Swift Evolution Proposal SE-0169: Improve Interaction Between private Declarations and Extensions"
 */

struct SortedArray<Element: Comparable> {
    private var storage: [Element] = []
    init(unsorted: [Element]) {
        storage = unsorted.sorted()
    }
}

extension SortedArray {
    mutating func insert(_ element: Element) {
        // storage является "видимой" здесь
        storage.append(element)
        storage.sort()
    }
}
var array = SortedArray(unsorted:[4,1,3])
array.insert(2)

// storage "НЕвидима" здесь. Она была бы "видна",
// если бы имела уровень доступа fileprivate.

//array.storage // error: 'storage' is inaccessible due to 'private' protection level

/*:
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous)
 */
