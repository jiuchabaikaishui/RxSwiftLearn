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
        
        Observable.just([1, 2, 3]).bind(to: pickerView1.rx.itemTitles, curriedArgument: { "\($1)" }).disposed(by: bag)
        pickerView1.rx.itemSelected.subscribe(onNext: { (row, component) in
            print("选中了第\(component)列第\(row)行")
            }).disposed(by: bag)
        pickerView1.rx.modelSelected(Int.self).subscribe(onNext: { (index) in
                print("选中了元素\(index.first ?? 0)")
                }).disposed(by: bag)
    }
}
