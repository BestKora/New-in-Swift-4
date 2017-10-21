/*:
## Умные key paths
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)

Одна из главных особенностей Swift 4 - это новая модель ключей пути (key paths), описанная в [SE-0161].
 В отличии от строковых ключей пути в Cocoa, в Swift ключи пути строго типизированны.

[SE-0161]: https://github.com/apple/swift-evolution/blob/master/proposals/0161-key-paths.md "Swift Evolution Proposal SE-0161: Smart KeyPaths: Better Key-Value Coding for Swift"
*/

import Foundation

//============== Для структур ==================
struct GoodPerson {
    let name: String
    
    func greet() {
        print("Hello \(name)!")
    }
}

let p = GoodPerson(name: "Samus")
let greeter = p.greet // запоминаем метод без его оценки.
greeter() // вызываем запомненный метод

// это единственный способ в Swift 3.2 запомнить имя свойства
// GoodPerson и сослаться на него позже при вычислении

//Старый способ запомнить ссылку на свойство
//------------- в Swift 3.2 ------------------
let getName = { (p: GoodPerson) in p.name } // => Samus
print(getName(p)) // оцениваем свойство

//Новый способ запомнить ссылку на свойство
//------------- в Swift 4 --------------------
let nameKp = \GoodPerson.name
print(p[keyPath: nameKp])                  // => Samus

//=============== Для классов =================
class PersonVIP: NSObject {
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var friends: [PersonVIP] = []
    @objc dynamic var bestFriend: PersonVIP?
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}
let chris = PersonVIP(firstName: "Chris", lastName: "Lattner")
let joe = PersonVIP(firstName: "Joe", lastName: "Groff")
let douglas = PersonVIP(firstName: "Douglas", lastName: "Gregor")
chris.friends = [joe, douglas]
chris.bestFriend = joe
//--------------- в Swift 3.2 - строковые key payhs -----------------------------------
let firstName = #keyPath(PersonVIP.firstName) // => "firstName"
chris.value( forKey:firstName) // => Chris
let lastNameBestFriend =
    #keyPath(PersonVIP.bestFriend.lastName) // => "bestFriend.lastName"
chris.value( forKeyPath:lastNameBestFriend) // => Groff
let friends =
    #keyPath(PersonVIP.friends.firstName) // => "friends.firstName"
chris.value( forKeyPath:friends) // => ["Joe", "Douglas"]

//-------------- в Swift 4 типизованные key payhs ------------------------------------
let firstNameKp = \PersonVIP.firstName
chris[keyPath: firstNameKp] // => Chris
let lastNameBestFriendKp = \PersonVIP.bestFriend?.lastName
chris[keyPath: lastNameBestFriendKp] // => Groff

// KeyPaths не реализованы для subscripts
// let friendsFirstNameKp = \PersonVIP.friends.firstName

// Но можно использовать map
let friendsKp = \PersonVIP.friends
let friendsCris = chris[keyPath: friendsKp].map{$0.firstName}
// => ["Joe", "Douglas"]
print (friendsCris)

//Можно использовать цепочки Optionals
let friendsFirstFirstNameKp = \PersonVIP.friends.first?.firstName
let aFriends = chris[keyPath: friendsFirstFirstNameKp] // => Joe
//--------------------------------------------------------------------

/*:
 Вот классический пример использования новых типизованных key paths
*/

struct Person {
    var name: String
}

struct Book {
    var title: String
    var authors: [Person]
    var primaryAuthor: Person {
        return authors.first!
    }
}

let abelson = Person(name: "Harold Abelson")
let sussman = Person(name: "Gerald Jay Sussman")
let book = Book(title: "Structure and Interpretation of Computer Programs",
              authors: [abelson, sussman])

/*:
 Key paths формируются, начиная с корневого типа и затем мы можем идти вниз по иерархии до любой комбинации имен свойств и подписки (subscript).
 
 Вы пишите key path, начиная с обратного слеша: `\Book.title`. Каждый тип автоматически снабжается подпиской `[keyPath: …]` для получения и установки значения для определенного key path.
 */
book[keyPath: \Book.title]
// Key paths могут опускаться вниз по иерархии до любого уровня
// Они также работают и для вычисляемых (computed) свойств
book[keyPath: \Book.primaryAuthor.name]

/*:
 Key paths являются объектами, которые можно хранить и ими можно манипулировать. Например, вы можете добавить дополнительный сегмент к key path, чтобы спуститься еще дальше по иерархии.
 */
let authorKeyPath = \Book.primaryAuthor

// Вы можете пропустить имя типа, если
// компилятор может вывести его из контекста
let nameKeyPath = authorKeyPath.appending(path: \.name)
book[keyPath: nameKeyPath]

/*:
 ### Key paths for subscripts
 
 Key paths также будут работать с subscripts. Довольно удобный способ для работы с коллекциями, массивами или словарями. Эта функциональность пока еще не реализована  в Swift 4.0, возможно мы увидим их в версии Swift 4.1.
 */

//book[keyPath: \Book.authors[0].name]
// error: key path support for subscript components is not implemented
 
 /*:
 ### Type-безопасное KVO с key paths
 
 KVO API в Foundation существенно переделан и использует все преимущества новых type-безопасных key paths.
 Это намного легче, чем старое API.
 
 Заметьте, что KVO зависит от Objective-C runtime. Оно работает только с subclasses `NSObject`, и любые наблюдаемые (observable) свойства должны декларироваться как `@objc dynamic`.
 */

class Foo: NSObject {
    // KVO свойства должны быть @objc dynamic
    
    @objc dynamic var string: String
    
    override init() {
        string = "hotdog"
        super.init()
    }
}

let foo = Foo()

// Устанавливаем KVO всего 3 строками кода!
let observation = foo.observe(\.string, options: [.initial, .old]) { (foo, change) in
    if let oldValue = change.oldValue {
        print("изменили значение \"\(oldValue)\" на новое \"\(foo.string)\"")
    }
}

foo.string = "not hotdog"
//изменили значение "hotdog" на новое "not hotdog"
//--------------
/*:
 Еще один пример использования KeyPaths c optional свойствами:
 */

struct Person1 {
    var address: Address?
}
struct Address {
    var street:String
    var zip:String
    var city:String
    var state:String
}
struct Friend {
    var name: String
    var addresses: [Address]
    
    var primaryAddress: Address {
        return addresses.first!
    }
}
let address1 = Address(street: "Apple Bay Street", zip: "94608", city: "Emeryville", state: "California")
let address2 = Address(street: "27th Way", zip: "85042", city: "Phoenix", state: "Arizona")
let friend = Friend(name: "Steve Jobs", addresses: [address1,address2])

let p1 = Person1(address: Address(street: "Apple Bay Street", zip: "94608", city: "Emeryville", state: "California"))
let kp = \Person1.address?.state
p1[keyPath: kp]
friend[keyPath:\Friend.primaryAddress.state]


//---------------------------------------------------------------------
let firstStringLength = \[String].first?.count
let length = ["abc","cd", "f" ][keyPath: firstStringLength]

/*:
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
 */


