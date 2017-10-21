/*:
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
 
 ## Generic subscripts
 
 Благодаря предложению [SE-0148][SE-0148], subscripts могут теперь иметь generic аргументы и/или возвращаемые типы.
 
 [SE-0148]: https://github.com/apple/swift-evolution/blob/master/proposals/0148-generic-subscripts.md "Swift Evolution Proposal SE-0148: Generic Subscripts"
 
 Канонический пример использования generic subscripts - это тип, который представляет JSON данные: вы можете определить generic subscript для того, чтобы контекст вызова определил ожидаемый возвращаемый тип.
 */

struct JSON {
    private var storage: [String:Any]
    
    init(dictionary: [String:Any]) {
        self.storage = dictionary
    }
    
    subscript<T>(key: String) -> T? {
        return storage[key] as? T
    }
}

let json = JSON(dictionary: [
    "name": "Berlin",
    "country": "de",
    "population": 3_500_500
    ])

// Нет необходимости в использовании as? Int
let population: Int? = json["population"]

/*:
 Другой пример: subscript `Collection`, который берет generic последовательность индексов и возвращает массив значений для этих индексов `indices`:
 */

extension Collection {
    subscript<Indices: Sequence>(indices indices: Indices) -> [Element]
                                       where Indices.Element == Index {
        var result: [Element] = []
        for index in indices {
            result.append(self[index])
        }
        return result
    }
}

let words = "Каждый охотник желает знать, где сидит фазан.".split(separator: " ")
words[indices: [1,2]]

/*:
[Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
 */

