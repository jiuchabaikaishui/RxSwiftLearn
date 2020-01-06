//
//  SimplePickerViewViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/25.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SimplePickerViewViewController: ExampleViewController {
    @IBOutlet weak var pickerView1: UIPickerView!
    @IBOutlet weak var pickerView2: UIPickerView!
    @IBOutlet weak var pickerView3: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable.just([1, 2, 3, 4, 5, 6, 7, 8, 9]).bind(to: pickerView1.rx.itemTitles, curriedArgument: { "\($1)" }).disposed(by: bag)
        pickerView1.rx.itemSelected.subscribe(onNext: { print("选中了第\($1)列第\($0)行") }).disposed(by: bag)
        pickerView1.rx.modelSelected(Int.self).subscribe(onNext: { print("选中了元素\($0.first ?? 0)") }).disposed(by: bag)
        
        Observable.just([1, 2, 3, 4, 5, 6, 7, 8, 9]).bind(to: pickerView2.rx.itemAttributedTitles, curriedArgument: { NSAttributedString(string: "\($1)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.random]) }).disposed(by: bag)
        pickerView2.rx.itemSelected.subscribe(onNext: { print("选中了第\($1)列第\($0)行") }).disposed(by: bag)
        pickerView2.rx.modelSelected(Int.self).subscribe(onNext: { print("选中了元素\($0.first ?? 0)")
            }).disposed(by: bag)
        
        Observable.just(Array(0..<10).map({ (_) -> UIColor in UIColor.random })).bind(to: pickerView3.rx.items, curriedArgument: { _, color, _ in
            let view = UIView()
            view.backgroundColor = color
            return view
        }).disposed(by: bag)
        pickerView3.rx.itemSelected.subscribe(onNext: { print("选中了第\($1)列第\($0)行") }).disposed(by: bag)
        pickerView3.rx.modelSelected(UIColor.self).subscribe(onNext: { print("选中了元素\($0.first ?? UIColor.white)") }).disposed(by: bag)
    }
}
