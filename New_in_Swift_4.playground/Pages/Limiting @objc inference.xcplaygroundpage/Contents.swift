/*:
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
 
 ## Ограничение `@objc` экспонирования
 
 Во многих местах, где Swift 3 автоматически делает вывод о том, что декларирование должно быть помечено атрибутом `@objc` (и таким образом оказывается "видимым" для Objective-C), Swift 4 больше этого не делает ([SE-0160][SE-0160]). Еще более важно то, что `NSObject` subclasses больше не добавляют `@objc` для его членов.
 
 [SE-0160]: https://github.com/apple/swift-evolution/blob/master/proposals/0160-objc-inference.md "Swift Evolution Proposal SE-0160: Limiting @objc inference"
 */

import Foundation

class MyClass : NSObject {
    func foo() { }       // не экспонируется для Objective-C в Swift 4
    @objc func bar() { } // явно экспонируется для Objective-C
}

/*:
 ### `@objcMembers` shorthand
 
 Если вы хотите экспонировать все или почти все элементы класса для Objective-C, вы можете использовать атрибут `@objcMembers` при декларировании класса:
 */

@objcMembers
class MyClass2 : NSObject {
    func foo() { }             // неявно @objc
    func bar() -> (Int, Int) { // нет @objc, из-за того, что кортеж не представлен в
                               //Objective-C (ничего не изменилось со времен Swift 3)
        return (0, 0)
    }
}

/*:
 Используйте `@nonobjc` в расширениях `extension` для того, чтобы убрать экспонирование `@objc`(через `@objcMembers`) для всех деклараций в расширении `extension`.
 */

@nonobjc extension MyClass2 {
    func wobble() { } // нет @objc несмотря на @objcMembers
}

/*:
 ### `dynamic` не вызывает неявного экспонирования `@objc`
 
 Заметьте также, что `dynamic` не вызывает больше неявного экспонирования `@objc`. Если вы хотите использовать возможности, которые зависят от динамического диспетчирования Objective-C runtime (таких, как KVO), то вам необходимо добавить при декларировании атрибуты `@objc dynamic`. Смотри [Key paths страницу](Key%20paths),на которой представлен пример KVO.
 
 Так как `dynamic` в настоящее время реализован в смысле Objective-C runtime, то использование `dynamic` обязательно означает присутствие `@objc`. В настоящий момент это кажется избыточным, но это существенный шаг к тому, чтобы сделать `dynamic` чисто Swift возможностью в будущих версиях Swift.
 */
/*:
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
 */

