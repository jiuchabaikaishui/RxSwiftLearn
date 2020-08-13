//
//  NumbersViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/25.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class NumbersViewController: ExampleViewController {
    @IBOutlet weak var number1: UITextField!
    @IBOutlet weak var number2: UITextField!
    @IBOutlet weak var number3: UITextField!
    @IBOutlet weak var result: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 绑定UI
        Observable.combineLatest(number1.rx.text.orEmpty,
                                 number2.rx.text.orEmpty,
                                 number3.rx.text.orEmpty)
            { (value1, value2, value3) -> Int in
                return (Int(value1) ?? 0) + (Int(value2) ?? 0) + (Int(value3) ?? 0)
            }.map { $0.description }
            .bind(to: result.rx.text)
            .disposed(by: bag)
    }
}
