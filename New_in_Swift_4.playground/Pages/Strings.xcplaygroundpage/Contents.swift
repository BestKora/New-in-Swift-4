/*:
 [Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
### String опять стала `Collection`

[SE-0163][SE-0163] - это первая часть пересмотренной Модели строки `String` в Swift 4. Существенные изменения состоят в том, что `String` теперь опять стала коллекцией `Collection` (как это было в Swift 1.x), то есть функциональность `String.CharacterView` включена в родительский тип. (Другие views, `UnicodeScalarView`, `UTF8View`, и `UTF16View`, все еще присутствуют в `String`.)

[SE-0163]: https://github.com/apple/swift-evolution/blob/master/proposals/0163-string-revision-1.md "Swift Evolution Proposal SE-0163: String Revision: Collection Conformance, C Interop, Transcoding"
[SE-0180]: https://github.com/apple/swift-evolution/blob/master/proposals/0180-string-index-overhaul.md "Swift Evolution Proposal SE-0180: String Index Overhaul"
*/
import Foundation

var greeting = "Пивет,прекрасный Мир!!"
let rev = String(greeting.reversed())
greeting.isEmpty
greeting.count
greeting.dropFirst()
let filtered = greeting.filter { $0 != "!" }
filtered


/*:
 ### `Substring` - это новый тип для строковых слайсов
 
 String слайсы являются экземплярами типа `Substring`. Как `String`, так и `Substring` "подтверждают" протокол `StringProtocol`. Большая часть API для строк находится в протоколе `StringProtocol`, так что `String` и `Substring` ведут себя в большинстве случаев похожим образом.
 */
greeting = "Каждый охотник желает знать, где сидит фазан."
let parts = greeting.split(separator: " ")
// parts - это массив [Substring], а не [String].
type(of: parts)

let comma = greeting.index(of: ",")!
let substring = greeting[..<comma]
type(of: substring)

let beginning = greeting.prefix(11)
type(of: beginning)

let beginningString = String(beginning)
type(of: beginningString)

greeting = "Hello, friend!!!"
if let i = greeting.index(where: { $0 >= "A" && $0 <= "Z" }) {
    greeting[i]
    type(of: greeting[i])
}


// Большая часть String APIs может использоваться с Substring
substring.uppercased()
/*:
Подстрока `Substring` "держит" полную строку `String`, из которой она создана. Это может приводить к случайному очень большому увеличению использования "памяти" при передачи казалось бы маленьких подстрок `Substring`, которые держат большую строку `String`, в другие API. По этой причине большинство функций, которые получают в качестве аргумента строку, должны принимать только строку, то есть экземпляр `String`; вам не следует делать эти функции generic и принимать любое значение, "подтверждающее" протокол `StringProtocol`.

Для обратного преобразования `Substring` в `String`, используйте инициализатор  `String()`. Это приведет к копированию подстроки в новый буфер:
*/
let newString = String(substring)
type(of: newString)

/*:
 Unicode 9: Swift 4 поддерживает Unicode 9, обеспечивая правильную работу с кластером графем для современных эмодзи, когда несколько кодовых пунктов сгруппированы в один кластер, который действует как один символ.
 [Emoji 4.0]: https://oleb.net/blog/2016/12/emoji-4-0/
 */

// папа
var family = "👨"
// мама
family += "\u{200D}👩"
family.count

// добавляем одну дочку
family += "\u{200D}👧"
// добавляем одного сына
family += "\u{200D}👦"
family.count // 1
family.contains("👧") // true

let s = family.unicodeScalars.flatMap {
    $0 != "\u{200D}" ? String($0) :nil }

family.unicodeScalars.forEach {
    if $0 != "\u{200D}" {
        print("\($0) ")}
}

// для исследования содержимого класторных графем применяется
// хорошо известная функция 'applyingTransform'
family.applyingTransform(.toUnicodeName, reverse: false)!
    .replacingOccurrences(of: "\\N", with: "")
    .components(separatedBy: CharacterSet(charactersIn: "{}"))
    .filter { $0 != "" }

// Во всех случаях, представленных ниже, подсчет символов производится правильно (чего не было в Swift 3):

"👧🏽".count // person + skin tone; в Swift 3: 2
"👨‍👩‍👧‍👦".count // семья их 4-х человек; в Swift 3: 4
"👱🏾\u{200D}👩🏽\u{200D}👧🏿\u{200D}👦🏻".count // family + skin tones; в Swift 3: 8
"👩🏻‍🚒".count // person + skin tone + profession; в Swift 3: 3
"🇨🇺🇬🇫🇱🇨".count // множество флагов; в Swift 3: 1


/*:
 ### Появилось свойство `Character.unicodeScalars`
 
 Теперь у вас есть прямой доступ к свойству unicodeScalars у `Character`, без предварительной конвертации в `String` ([SE-0178][SE-0178]):
 
 [SE-0178]: https://github.com/apple/swift-evolution/blob/master/proposals/0178-character-unicode-view.md "Swift Evolution Proposal SE-0178: Add `unicodeScalars` property to `Character`"
 */
let c: Character = "🇨🇺"
Array(c.unicodeScalars)
/*:
### Многострочные литералы

[SE-0168][SE-0168] представляет простейший синтаксис для могострочных строковых литералов, используя три двойнык кавычки (`"""`). Внутри многострочного литерала не нужно экранировать одинарные кавычки, что означает, что такие форматы, как JSON и HTML, могут быть вставлены в них безо всякого экранирования. Отступ закрывающего литерала `"""` определяет, сколько пробелов будет удалено с начала каждой строки.

[SE-0168]: https://github.com/apple/swift-evolution/blob/master/proposals/0168-multi-line-string-literals.md "Swift Evolution Proposal SE-0168: Multi-Line String Literals"
*/
let messageSwift3 = "Есть свойства, бестелесные явленья,\nС двойною жизнью; тип их с давних лет, — \nТа двойственность, что поражает зренье: \nТо — тень и сущность, вещество и свет.\n\nЕсть два молчанья, берега́ и море,\nДуша и тело. Властвует одно\nВ тиши. Спокойно нежное, оно\nВоспоминаний и познанья горе\n\nТаит в себе, и «больше никогда»\nЗовут его. Телесное молчанье,\nОно бессильно, не страшись вреда!\n\n"
print (messageSwift3)

let multilineString = """
        Есть свойства, бестелесные явленья,
        С двойною жизнью; тип их с давних лет, —
        Та двойственность, что поражает зренье:
        То — тень и сущность, вещество и свет.

        Есть два молчанья, берега́ и море,
        Душа и тело. Властвует одно
        В тиши. Спокойно нежное, оно
        Воспоминаний и познанья горе

        Таит в себе, и «больше никогда»
        Зовут его. Телесное молчанье,
        Оно бессильно, не страшись вреда!
"""
print(multilineString)
print("---")

let message = """
Put your text in "quotes" to make them look quoted.
"""

/*:
### Как избежать новых строк в многострочных литералах

[SE-0182][SE-0182] добавляет возможность удаления начала новых строк в многострочных литералах с помощью обратного слэша в конце строки.

[SE-0182]: https://github.com/apple/swift-evolution/blob/master/proposals/0182-newline-escape-in-strings.md "Swift Evolution Proposal SE-0182: String Newline Escaping"
*/
let escapedNewline = """
Для пропуска прерывания строки \
добавляем обратный слэш в конце этой строки.
"""
print(escapedNewline)
print("---")

/*:
 [Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
 */
