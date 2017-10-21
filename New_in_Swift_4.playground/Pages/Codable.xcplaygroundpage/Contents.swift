/*:
 [Содержание](Table%20of%20contents) • [Следующая страница](@next)
 
 ## Архивирование и сеарилазация
 
 [SE-0166: Swift Archival & Serialization][SE-0166] определяет, каким образом любые Swift типы (классы `classes`, структуры `structs` или  перечисления `enums`) могут описать свое архивирование или сериализацию. Для этого они должны подтвердить пртокол `Codable`.
 
 В большинстве случаев подтверждение протокола `Codable` - это все, что нужно сделать для вашего пользовательского типа, а компилятор сгенерирует реализацию по умолчанию, если все элементы вашего пользовательского типа являются `Codable`. Но в случае необходимости вы можете переопределить поведение по умолчанию, если вам необходимо организовать архивирование или сериализацию особым образом. Эта тема очень многогранная - для изучения деталей лучше познакомиться с предложение [SE-0166: Swift Archival & Serialization][SE-0166] .
 
 [SE-0166]: https://github.com/apple/swift-evolution/blob/master/proposals/0166-swift-archival-serialization.md "Swift Evolution Proposal SE-0166: Swift Archival & Serialization"
 
 */
// Делает пользовательский тип архивируемым подтверждая протокол `Codable` вместе со своими элементамиe

import Foundation

struct Conference: Codable {
    let name: String
    let city: String
    let date : Date
}

let wwdc = Conference(name: "WWDC",
                      city: "San Jose",
                      date: Date(timeIntervalSince1970: 0))

let jsonEncoder = JSONEncoder()
let dateFormatter = DateFormatter()
dateFormatter.dateStyle = .long
dateFormatter.timeStyle = .long
jsonEncoder.dateEncodingStrategy =
         JSONEncoder.DateEncodingStrategy.formatted(dateFormatter)
let jsonEncoded = try jsonEncoder.encode(wwdc)
let jsonString = String(data: jsonEncoded, encoding: .utf8)

let jsonDecoder = JSONDecoder()
jsonDecoder.dateDecodingStrategy =
     JSONDecoder.DateDecodingStrategy.formatted(dateFormatter)
let decodedWWDC = try jsonDecoder.decode(Conference.self, from: jsonEncoded)

let jsonString1 = """
{   "title": "Blah",
"frontCover": {},
"backCover": { "image": "", "text": "It's good, read it" }
}
"""
struct BookCover: Decodable {
    var text: String?
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case text
        case image
    }
    
}

struct Book: Decodable {
    var title: String
    var frontCover: BookCover?
    var backCover: BookCover?
}

if let data = jsonString1.data(using: .utf8) {
    let decoder = JSONDecoder()
    
    if let book = try? decoder.decode(Book.self, from: data) {
        print(book.title) // "War and Peace: A protocol oriented approach to diplomacy"
    }
    
}
/*:
 [Содержание](Table%20of%20contents) • [Следующая страница](@next)
 */
