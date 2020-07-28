//
//  ValuesViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/25.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ValuesViewController: ExampleViewController {
    @IBOutlet weak var a: UITextField!
    @IBOutlet weak var b: UITextField!
    @IBOutlet weak var c: UILabel!
    @IBOutlet weak var d: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 命令式代码
        if ((Int(a.text ?? "") as Int?) ?? 0) + ((Int(b.text ?? "") as Int?) ?? 0) >= 0 {
            c.text = "c = \(Int(a.text!)! + Int(b.text!)!) is positive"
        }
        
        // RxSwif代码
        let aValue = 1, bValue = 2
        a.text = "\(aValue)"
        b.text = "\(bValue)"
        let aOb = BehaviorRelay(value: aValue)
        let bOb = BehaviorRelay(value: bValue)
        a.rx.text.orEmpty
            .map { Int($0) ?? 0 }
            .subscribe(onNext: { (v) in
                aOb.accept(v)
            }).disposed(by: bag)
        b.rx.text.orEmpty
            .map { Int($0) ?? 0 }
            .subscribe(onNext: {
                bOb.accept($0)
            }).disposed(by: bag)
        Observable.combineLatest(aOb, bOb, resultSelector: +)
            .filter { $0 > 0 }
            .map { "d = \($0) is positive" }
            .bind(to: d.rx.text)
            .disposed(by: bag)
    }
}
