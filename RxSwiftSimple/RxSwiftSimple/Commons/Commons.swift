//
//  Commons.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/8/7.
//  Copyright © 2019 QSP. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class DefaultWireFrame: WireFrame {
    func open(_ url: URL) {
        UIApplication.shared.open(url)
    }
    
    private static func rootViewController() -> UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    /// 提示框
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    ///   - cancelAction: 取消按钮
    ///   - actions: 其他按钮
    ///   - animated: 动画
    ///   - completion: 完成操作
    func promptFor<Action: CustomStringConvertible>(_ title: String, message: String, cancelAction: Action, actions: [Action]? = nil, animated: Bool = true, completion: (() -> Void)? = nil) -> Observable<Action> {
        return Observable.create({ (observer) -> Disposable in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: cancelAction.description, style: .cancel, handler: { (_) in
                observer.onNext(cancelAction)
            }))
            
            if let  actions = actions {
                for action in actions {
                    alert.addAction(UIAlertAction(title: action.description, style: .default, handler: { (_) in
                        observer.onNext(action)
                    }))
                }
            }
            
            DefaultWireFrame.rootViewController().present(alert, animated: animated, completion: completion)
            
            return Disposables.create { [weak alert] in
                alert?.dismiss(animated: animated, completion: nil)
            }
        })
    }
}

func nonMarkedText(_ textInput: UITextInput) -> String? {
    let start = textInput.beginningOfDocument
    let end = textInput.endOfDocument
    
    guard let rangeAll = textInput.textRange(from: start, to: end), let text = textInput.text(in: rangeAll) else {
        return nil
    }
    
    guard let markTextRange = textInput.markedTextRange else {
        return text
    }
    
    guard let startRange = textInput.textRange(from: start, to: markTextRange.start), let endRange = textInput.textRange(from: end, to: markTextRange.end) else {
        return text
    }
    
    return (textInput.text(in: startRange) ?? "") + (textInput.text(in: endRange) ?? "")
}
infix operator <->: AdditionPrecedence
func <-><Base>(textInput: TextInput<Base>, relay: BehaviorRelay<String>) -> Disposable {
    let bind = relay.bind(to: textInput.text)
    let bindRelay = textInput.text.subscribe(onNext: { (n) in
        if let nonMarkedText = nonMarkedText(textInput.base), nonMarkedText != relay.value {
            relay.accept(nonMarkedText)
        }
    }, onCompleted: {
        bind.dispose()
    })
    
    return Disposables.create(bind, bindRelay)
}
func <-><T>(property: ControlProperty<T>, relay: BehaviorRelay<T>) -> Disposable {
#if DEBUG
    if T.self == String.self {
        fatalError("删除这个信息也是可以的，但是这是在提醒开发者有可能试着将一些“rx.text”属性绑定到relay。\n" +
            "这通常能够很好的工作，但是对于一些IME语言这种简单的方法将造成意外的问题，因为当文本正在输入时将会返回中间结果。\n" +
            "解决方案: 就是使用 `textField <-> relay` 替换 `textField.rx.text <-> relay`.\n" +
        "了解更多: https://github.com/ReactiveX/RxSwift/issues/649\n")
    }
#endif
    
    let bind = relay.bind(to: property)
    let bindRelay = property.subscribe(onNext: { (n) in
        relay.accept(n)
    }, onCompleted: {
        bind.dispose()
    })
    
    return Disposables.create(bind, bindRelay)
}
