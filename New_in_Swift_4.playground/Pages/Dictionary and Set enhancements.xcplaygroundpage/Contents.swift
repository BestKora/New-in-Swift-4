/*:
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)

## Улучшения в словаре `Dictionary` и множестве `Set`

Предложение [SE-0165][SE-0165] добавило несколько улучшений в `Dictionary` и `Set`.

[SE-0165]: https://github.com/apple/swift-evolution/blob/master/proposals/0165-dict.md "Swift Evolution Proposal SE-0165: Dictionary and Set Enhancements"

Массив продуктов `groceries` мы будем использовать для создания и преобразования словарей с применением новых инструментов.
*/
import Foundation

struct GroceryItem: Hashable {
    var name: String
    var department: Department
    
    enum Department {
        case bakery, produce, seafood
    }
    
    static func ==(lhs: GroceryItem, rhs: GroceryItem) -> Bool {
        return (lhs.name, lhs.department) == (rhs.name, rhs.department)
    }
    
    var hashValue: Int {
        // Combine the hash values for the name and department
        return name.hashValue << 2 | department.hashValue
    }
}

// Создание некоторых продуктов для нашего магазина:
let 🍎 = GroceryItem(name: "Apples", department: .produce)
let 🍌 = GroceryItem(name: "Bananas", department: .produce)
let 🥐 = GroceryItem(name: "Croissants", department: .bakery)
let 🐟 = GroceryItem(name: "Salmon", department: .seafood)
let 🍇 = GroceryItem(name: "Grapes", department: .produce)
let 🍞 = GroceryItem(name: "Bread", department: .bakery)
let 🍤 = GroceryItem(name: "Shrimp", department: .seafood)

let groceries = [🍎, 🍌, 🥐, 🐟, 🍇, 🍞, 🍤]
/*:
 ### Sequence-based initializer

 Создание словаря из последовательности значений `values`, сгруппированных по ключам, которые вычисляются из самих этих значений `values`.
 */

let groceriesByDepartment = Dictionary(grouping: groceries,
                                       by: { item in item.department })
groceriesByDepartment[.bakery]! == [🥐, 🍞]

/*:
 или по первой букве в названии продукта.
 */

let groceriesByFirstLetter = Dictionary(grouping: groceries,
                                       by: { $0.name.first! })
groceriesByFirstLetter["B"]! == [🍌,🍞]
/*:
Новый метод `mapValues` для преобразования значений `values` при сохранении структуры словаря.
 Из-за того, что словарь сохраняет те же самые ключи `keys`, просто для других значений `values`, то используется то же самое внутреннее взаиморасположение (internal layout), что и у оригинального словря и нет необходимости в перерасчете hash values. Это делает вызов `mapValues(_:)` более быстрым, чем создание словаря "с нуля".
*/

let departmentCounts = groceriesByDepartment.mapValues {
                                     items in items.count}
 departmentCounts[.bakery] == 2

let departmentNames = groceriesByDepartment.mapValues {
                                 $0.map{$0.name.uppercased()}}
departmentNames

/*:
 Создание словаря `Dictionary` из пар `key- value`, , используя два различных инициализатора: один - для уникальных ключей keys, другой - когда ключи keys повторяются.
 
 Если вы начинаете с последовательности ключей `keys` и последовательности значений `values`, вы можете комбинировать их в единую последовательность пар с помощью функции `zip(_:, _":)`.  Например, следующий код создает последовательность кортежей с именами name продуктов и самими продуктами:
 
 */

let zippedNames = zip(groceries.map { $0.name }, groceries)
/*:
Так как каждый продукт имеет уникальное имя, то следующий код успешно создаст словарь, который будет использовать имена в качестве ключей, а сами продукты в качестве значений:
 */

var groceriesByName = Dictionary(uniqueKeysWithValues: zippedNames)
 groceriesByName["Apples"] == 🍎
 groceriesByName["Kumquats"] == nil
/*:
 Используйте инициализатор `Dictionary(uniqueKeysAndValues:)` только, если вы уверены, что ваши даннын имеют уникальные ключи `keys`. Любые дублирующие ключи `keys` в последовательности приведут к ошибке на этапе runtime.
  */


/*:
 ### Merging инициализатор
 
 Если ваши данные имеют (или могут иметь) повторяющие ключи keys, используйте новый "сливающий" инициализатор `Dictionary(_:,uniquingKeysWith:)`. Этот инициализатор берет последовательность пар `key-value` наряду с замыканием , которое вызывается, когда ключ `key` повторяется. "Уникальное" замыкание берет в качестве аргументом первое и второе значения для одного и того же ключа `key`, и может вернуть существующее значение, новое значение или любую их комбинацию в зависимости от вашего решения.
 
 Например, следующий код преобразует массив кортежей `(String, String)` в словарь с применением функции `Dictionary(_:,uniquingKeysWith:)`. Заметьте, что "dog" является ключом key в двух парах `key-value`.
 */

let pairs = [("dog", "🐕"), ("cat", "🐱"), ("dog", "🐶"), ("bunny", "🐰")]
let petmoji = Dictionary(pairs,
                         uniquingKeysWith: { (old, new) in new })
petmoji
 petmoji["cat"] == "🐱"
 petmoji["dog"] == "🐶"
/*:
 Еще один пример
 
 */

let duplicates = [("a", 1), ("b", 2), ("a", 3), ("b", 4)]
let letters = Dictionary(duplicates, uniquingKeysWith: { (first, _) in first })
letters

/*:
 ### Выбор нужных значений с помощью `filter(_:)`.
 
 Словари Dictionaries теперь имеют метод `filter(_:)`, который возвращает словарь, а не массив пар `key-value`, как это было в более ранних версиях Swift. Методу `filter(_:)` передается замыкание, которое берет `key-value` пару в качестве его аргументов и возвращает `true`, если эта `key-value` пара должна войти в результирующий словарь `Dictionary`.
 */

func isFirstLetter(_ character: Character,
                        in name : String) -> Bool {
   return String(name.prefix(1)) == String (character)
}

let itemsByFirstLetter  =  groceriesByName.filter { (_, item)  in
    isFirstLetter("B",in:item.name)}
itemsByFirstLetter

let enoughtItems =  groceriesByDepartment.filter { (_, items)  in
    items.count > 2}
enoughtItems

/*:
  В `filter(_:)` можно играть с ключами.
 Выбираем только те ключи, которые начинаются с буквы "S":
 */
let itemsByFirstLetterKey  =  groceriesByName.filter { (key, _)  in
    isFirstLetter("S",in:key)}
itemsByFirstLetterKey
/*:
   Выбираем только четные ключи:
 */

let names = ["Cagney", "Lacey", "Bensen", "Carol"]
let dict = Dictionary(uniqueKeysWithValues: zip(1..., names))
let filtered = dict.filter {
    $0.key % 2 == 0
}
type(of: filtered)
filtered


/*:
 ### Subscript со значением по умолчанию
 
 Subscripts для словаря Dictionary в Swift 3 возвращал значение value, соответствующее указанному ключу key как Optional, так что обычно вам приходится использовать оператор ?? для установки значения по умолчанию для несуществующих ключей :

 */
var seasons = ["Spring" : 20, "Summer" : 30, "Autumn" : 10]
let winterTemperature = seasons["Winter"] ?? 0
/*:
 В Swift 4 у словарей Dictionaries теперь есть второй новый subscript  для ключей keys, который позволяет определить специальные значения для отсутствующих в словаре ключей keys. Благодаря этому новому subscript теперь нет необходимости в использовании оператора ?? для получения НЕ Optional значения:
  */

let winterTemperature1 = seasons["Winter", default: 0]

/*:
 Это особенно полезно, если вы хотите накапливать значение value через subscript:
 */
let source = "how now brown cow"
var frequencies: [Character: Int] = [:]
for c in source {
    frequencies[c, default: 0] += 1
}
frequencies

/*:
 Метод слияния merge - более простой способ проведения изменений "оптом", когда происходит добавление одного словаря целиком в другой:
 
 */
var cart = [🍌: 3, 🍞: 1]
let otherCart = [🍌: 2, 🍇: 3]
cart.merge(otherCart, uniquingKeysWith: +)
 cart == [🍌: 5, 🍇: 3, 🍞: 1]
/*:
 Еще один пример слияния НЕ ПО МЕСТУ - метод merging:
 */

let dictionary = ["a": 1, "b": 2, "c": 3]
let otherDictionary = ["a": 3, "b": 4]

let keepingCurrent = dictionary.merging(otherDictionary)
{ (current, _) in current }

let replacingCurrent = dictionary.merging(otherDictionary)
{ (_, new) in new }

/*:
 Фильтр `filter` для `Set`  также возвращает теперь `Set`, а не `Array`.
 */

let set: Set = [1,2,3,4,5]
let filteredSet = set.filter { $0 % 2 == 0 }
type(of: filteredSet)
filteredSet
let numberSet = Set(1 ... 100)
let twentyFivesOnly = numberSet.filter { $0 % 25 == 0 }
twentyFivesOnly
/*:
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
 */

