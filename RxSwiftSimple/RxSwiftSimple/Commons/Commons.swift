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
