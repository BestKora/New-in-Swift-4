/*:
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
 
 ## Ограничения для associatedtype
 
 [SE-0142][SE-0142]: теперь associatedtypes в протоколах protocols могут быть ограничены с помощью предложений `where`. Это казалось бы небольшое изменение делает систему типизации Swift более выразительной и содействует значительному упрощению стандартной библиотеки. В частности, в Swift 4 работать с последовательностью `Sequence` и коллекцией `Collection` стало намного проще и интуитивнее.
 
 [SE-0142]: https://github.com/apple/swift-evolution/blob/master/proposals/0142-associated-types-constraints.md "Swift Evolution Proposal SE-0142: Permit where clauses to constrain associated types"
 
 ### `Sequence.Element`
 
 Теперь последовательность `Sequence` имеет свой собственный associatedtype `Element`. Это стало возможным благодаря новым возможностям generics, так как теперь в типизованной системе можно написать следующее выражение `associatedtype Element where Element == Iterator.Element`.
 
 Везде, где раньше вы писали `Iterator.Element` в Swift 3, вы можете теперь просто написать `Element`:
 */

import Foundation

extension Sequence where Element: Numeric {
    var sum: Element {
        var result: Element = 0
        for element in self {
            result += element
        }
        return result
    }
}

[1,2,3,4].sum

/*:
 Другой пример: В Swift 3 это расширение extension требовало больше ограничений из-за того, что система типизации Swift 3 не могла выразить идею, что `Collection` associatedtype `Indices` представляет собой `Collection.Index`:
 
 // Это необходимо в Swift 3
 extension MutableCollection where Index == Indices.Iterator.Element {
 */
// В Swift 4 этого не нужно
extension MutableCollection {
    /// Проходит по всем элементам в коллекции и заменяет
    // по месту существующие элементы на значения,
    // полученные транформацией значений с помощью transform
    mutating func mapInPlace(_ transform: (Element) throws -> Element)
                                                             rethrows {
        for index in indices {
            self[index] = try transform(self[index])
        }
    }
}

/*:
Давайте определим API для запроса у менеджера модели `ModelManager` коллекции моделей `[Model]`.
 Помимо  associatedtype `Model`,нам нужно добавить еще два новых associatedtypes в наш протокол ModelManager:
   один - для запроса `Query` тип, который может быть каким угодно, например, `enum`, и который выбирает реализующий протокол. Затем мы собираемся добавить тип `Collection`, который мы ограничим так, что тип элемента возвращаемой из запроса коллекции `Collection` соответствует типу модели `Model`.
 Конечный результат выглядит так:
 */

protocol ModelManager {
    associatedtype Model
    associatedtype Collection: Swift.Collection where Collection.Element == Model
    associatedtype Query
    
    func models(matching query: Query) -> Collection
}

/*:
Например, при реализации `ModelManager` для модели `User`, мы можем использовать массив `Array` в качестве типа `Collection` и перечисление `enum` для запроса `Query`, который позволит нам выбирать пользователей по имени `name` и диапазону возрастов `ageRange`:
 */

struct User {
    var name = ""
    var age = 0
}

class UserManager: ModelManager {
    typealias Model = User
    var users = [User]()
    enum Query {
        case name(String)
        case ageRange(Range<Int>)
    }
    
    func models(matching query: Query) -> [User] {
        switch query {
        case .name(let nameQ):
            return users.filter { (user:User) in user.name == nameQ}
        case .ageRange(let range):
            return users.filter {range.contains($0.age)}
        }
    }
}

let Sasha = User(name: "Sasha", age: 13)
let Masha = User(name: "Masha", age: 23)
let Vera = User(name: "Vera", age: 40)
let userManager = UserManager()
userManager.users = [Sasha, Masha, Vera]
let v = userManager.models(matching: UserManager.Query.ageRange(Range(12...30)))

/*:
 Вот другой пример менеджера `MovieManager` отслеживает фильмы на основе их жанра `genre` и позволяет делать запросы по присутствию определенного текста `title` в названии фильма или по диапазону даты создания фильма:
 */

struct Movie {
    var title: String
    var genre: Genre
    var releaseYear: Int
}

enum Genre{
    case kidsFamily
    case sciFi
    case drama
    case romance
    case comedy
    case fantasy
    case animation
}

class MovieManager: ModelManager {
    typealias Model = (key: Genre, value: Movie)
    var movies = [(key: Genre, value: Movie)]()
    enum Query {
        case title(String)
        case yearRange(Range<Int>)
    }
    func models(matching query: Query) -> [Genre : Movie] {
        var result = [Genre : Movie]()
        switch query {
        case .title(let nameQ): do {
            for (key,value) in movies {
                if value.title.contains(nameQ){
                    result[key] = value
                }}}
        case .yearRange   (let range): do {
            for (key,value) in movies {
                if range.contains(value.releaseYear){
                    result[key] = value
                }}}
        }
        return result
    }
}

let movie1 = Movie(title: "Alladin", genre: Genre.kidsFamily, releaseYear: 1992)
let movie2 = Movie(title: "A Bug's Life", genre: Genre.kidsFamily, releaseYear: 1998)
let movie3 = Movie(title: "Beauty and the Beast", genre: Genre.romance, releaseYear: 1991)
let movie4 = Movie(title: "Big Hero 6", genre: Genre.comedy, releaseYear: 2014)
let movie5 = Movie(title: "Finding Nemo", genre: Genre.animation, releaseYear: 2003)
let movie6 = Movie(title: "The Little Mermaid", genre: Genre.fantasy, releaseYear: 1988)
let movie7 = Movie(title: "The Little Prince", genre: Genre.sciFi, releaseYear: 2016)
let mm = MovieManager()
mm.movies = [(key: Genre.kidsFamily, value: movie1),
             (key: Genre.kidsFamily, value: movie2),
             (key: Genre.romance, value: movie3),
             (key: Genre.comedy, value: movie4),
             (key: Genre.animation, value: movie5),
             (key: Genre.fantasy, value: movie6),
             (key: Genre.sciFi, value: movie7)]
let moviesY = mm.models(matching: MovieManager.Query.yearRange(Range(1990...2003)))
let moviesT = mm.models(matching: MovieManager.Query.title("Little"))
/*:
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
 */
