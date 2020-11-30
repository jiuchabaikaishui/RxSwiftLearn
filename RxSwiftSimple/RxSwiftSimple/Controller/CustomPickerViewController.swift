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
    @IBOutlet weak var centerPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if false {
            Observable.just([Array(0..<10), Array(10..<20), Array(20..<30)])
                .bind(to: pickerView.rx.items(adapter: SimpleSectionedPickerViewAdapter()))
                .disposed(by: bag)
        } else {
            pickerView.rx
                .items(adapter: SimpleSectionedPickerViewAdapter())(Observable.just([Array(0..<10), Array(10..<20), Array(20..<30)]))
                .disposed(by: bag)
        }
        pickerView.rx.itemSelected
            .subscribe(onNext: { print("选中了第\($1)列第\($0)行") })
            .disposed(by: bag)
        pickerView.rx.modelSelected(Int.self)
            .subscribe(onNext: { print("选中了元素\($0)") })
            .disposed(by: bag)
        
        let data = [Array(0..<10), Array(10..<100), Array(100..<1000)]
        if false {
            Observable.just(data)
                .bind(to: centerPickerView.rx.sectionedItems, curriedArgument: ({ (_, row, component, _) in
                    let label = UILabel()
                    label.font = UIFont.systemFont(ofSize: 12.0)
                    label.textAlignment = .center
                    label.backgroundColor = UIColor.random
                    label.text = data[component][row].description
                    return label
                }, { _, component in
                    switch component {
                    case 0:
                        return 40.0
                    case 1:
                        return 80.0
                    default:
                        return 120.0
                    }
                }, { (_, _) in 50.0 }, nil, nil))
                .disposed(by: bag)
        } else {
            centerPickerView.rx.sectionedItems(Observable.just(data))(({_, row, component, _ in
                let label = UILabel()
                label.font = UIFont.systemFont(ofSize: 12.0)
                label.textAlignment = .center
                label.backgroundColor = UIColor.random
                label.text = data[component][row].description
                return label
            }, { (_, component) in
                switch component {
                case 0:
                    return 40.0
                case 1:
                    return 80.0
                default :
                    return 120.0
                }
            }, { (_, _) in 50.0 }, nil, nil)).disposed(by: bag)
        }
    }
}
