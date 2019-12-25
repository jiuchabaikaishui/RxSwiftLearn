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
        
        if ((Int(a.text ?? "") as Int?) ?? 0) + ((Int(b.text ?? "") as Int?) ?? 0) >= 0 {
            c.text = "c = \(Int(a.text!)! + Int(b.text!)!) is positive"
        }
        
        Observable.combineLatest(a.rx.text.orEmpty.map({ Int($0) ?? 0 }), b.rx.text.orEmpty.map({ Int($0) ?? 0 })) { $0 + $1 }.filter {  $0 >= 0 }.map { "c = \($0) is positive" }.bind(to: d.rx.text).disposed(by: bag)
//        Observable.combineLatest(a.rx.text, b.rx.text, resultSelector: { ((Int($0!) as Int?) ?? 0) + ((Int($1!) as Int?) ?? 0) }).filter { $0 >= 0 }.map { "c = \($0) is positive"}.bind(to: d.rx.text).disposed(by: bag)
    }
}
