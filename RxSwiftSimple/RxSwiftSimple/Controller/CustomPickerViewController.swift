//
//  CustomPickerViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/26.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CustomPickerViewController: ExampleViewController {
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable.just([Array(0..<10), Array(10..<20), Array(20..<30)]).bind(to: pickerView.rx.items(adapter: PickerViewViewAdapter())).disposed(by: bag)
        pickerView.rx.itemSelected.subscribe(onNext: { print("选中了第\($1)列第\($0)行") }).disposed(by: bag)
        pickerView.rx.modelSelected(Int.self).subscribe(onNext: { print("选中了元素\($0)") }).disposed(by: bag)
    }
}
