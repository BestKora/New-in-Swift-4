/*:
 [Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
 
 ## Композиция классов `classes` и протоколов `protocols`
 
 [SE-0156][SE-0156]: Теперь вы можете писать в Swift эквивалент Objective-C кода `UIViewController <SomeProtocol> *`, то есть декларировать переменную конкретного типа и в то же время ограничить ее одним или несколькими протокалами. Синтаксис имеет следующий вид:`let variable: SomeClass & SomeProtocol1 & SomeProtocol2`.
 
 [SE-0156]: https://github.com/apple/swift-evolution/blob/master/proposals/0156-subclass-existentials.md "Swift Evolution Proposal SE-0156: Class and Subtype existentials"
 */

import UIKit

protocol Reloadable {
    var url: URL? {get set}
}

func reload(view: UIView & Reloadable) {
    
}
/*:
 Еще один пример:
 Мы хотим декларировать свойство как 'UIView', подтверждающее протокол 'HeaderView'
 */

protocol HeaderView {
    func setTitle(_ string: String)
}

class ParallaxView: UIView {
    let headerView: UIView & HeaderView
    
    init(frame: CGRect, headerView: UIView & HeaderView) {
        self.headerView = headerView
        super.init(frame: frame)
        
        addSubview(headerView)
        headerView.setTitle("Hello")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError()
    }
}
/*:
 Заставляем метку 'UILabel' подтвердить протокол 'HeaderView'
 */

extension UILabel: HeaderView {
    func setTitle(_ string: String) {
        text = string
    }
}
/*:
 Теперь любую метку 'UILabel' мы можем использовать для 'ParallaxView'
 */

let header = UILabel()
let p = ParallaxView(frame: .zero, headerView: header) // работает

// Мы не можем передать просто 'UIView', которое не подтверждает протокол 'HeaderView'
// ParallaxView(frame: .zero, headerView: UIView())

// У нас возникает ошибка, сообщающая о том, что аргумент типа 'UIView()' не соответствует ожидаемому типу 'UIView & HeaderView'

/*:
 [Содержание](Table%20of%20contents) • [Предыдущая страница](@previous) • [Следующая страница](@next)
 */
