//
//  SimpleBindingViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/25.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SimpleBindingViewController: ExampleViewController {
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var result: UILabel!
    
    struct Prime {
        let value: Int
        var isPrime: Bool {
            get {
                if value < 2 {
                    return false
                }
                for i in 2..<value {
                    if value%i == 0 {
                        return false
                    }
                }
                
                return true
            }
        }
    }
    func wolframAlphaIsPrime(_ value: Int) -> Observable<Prime> {
        return Observable<Prime>.create({ (observer) -> Disposable in
            observer.onNext(Prime(value: value))
            observer.onCompleted()
            
            return Disposables.create()
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        number.rx.text.map { [unowned self] in self.wolframAlphaIsPrime( Int($0 ?? "") as Int? ?? 0) }.concat().map { "\($0.value) \($0.isPrime ? "是" : "不是")素数！" }.bind(to: result.rx.text).disposed(by: bag)
        number.text = "43"
        number.sendActions(for: .editingDidEnd)
    }
}
