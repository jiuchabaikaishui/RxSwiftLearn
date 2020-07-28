//
//  InputIValidationViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/25.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class InputIValidationViewController: ExampleViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var error: UILabel!
    
    enum Availability {
        case available(message: String)
        case taken(message: String)
        case invalid(message: String)
        case pending(message: String)
        
        var message: String {
            switch self {
            case .available(let message),
                 .taken(let message),
                 .invalid(let message),
                 .pending(let message):
                
                return message
            }
        }
    }
    struct API {
        static func usernameAvailable(_ username: String) -> Observable<Bool> {
            return Observable<Bool>.create({ (observer) -> Disposable in
                DispatchQueue.global().async {
                    Thread.sleep(forTimeInterval: TimeInterval(2 + arc4random()%3))
                    DispatchQueue.main.async {
                        if arc4random()%2 == 0 {
                            observer.onNext(false)
                        } else {
                            observer.onNext(true)
                        }
                    }
                }
                
                return Disposables.create()
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.rx.text
            .map { (n) -> Observable<Availability> in
                guard let username = n, !username.isEmpty else {
                    return Observable.just(.invalid(message: "用户名不能为空."))
                }
                
                let loadingValue = Availability.pending(message: "检查可用性……")
                return API.usernameAvailable(username).map({ (available) -> Availability in
                    if available {
                        return .available(message: "用户名有效")
                    } else {
                        return .invalid(message: "用户名无效")
                    }
                }).startWith(loadingValue)
            }.switchLatest().subscribe(onNext: { [unowned self] (validity) in
                self.error.text = validity.message
            }).disposed(by: bag)
    }
}
