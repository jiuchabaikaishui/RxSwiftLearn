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
    func promptFor<Action: CustomStringConvertible>(_ title: String, message: String, cancelAction: Action, actions: [Action], animated: Bool = true, completion: (() -> Void)? = nil) -> Observable<Action> {
        return Observable.create({ (observer) -> Disposable in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: cancelAction.description, style: .cancel, handler: { (_) in
                observer.onNext(cancelAction)
            }))
            for action in actions {
                alert.addAction(UIAlertAction(title: action.description, style: .default, handler: { (_) in
                    observer.onNext(action)
                }))
            }
            
            DefaultWireFrame.rootViewController().present(alert, animated: animated, completion: completion)
            
            return Disposables.create {
                alert.dismiss(animated: animated, completion: {
                    observer.onNext(cancelAction)
                })
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
        fatalError("It is ok to delete this message, but this is here to warn that you are maybe trying to bind to some `rx.text` property directly to relay.\n" +
            "That will usually work ok, but for some languages that use IME, that simplistic method could cause unexpected issues because it will return intermediate results while text is being inputed.\n" +
            "REMEDY: Just use `textField <-> relay` instead of `textField.rx.text <-> relay`.\n" +
        "Find out more here: https://github.com/ReactiveX/RxSwift/issues/649\n")
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
