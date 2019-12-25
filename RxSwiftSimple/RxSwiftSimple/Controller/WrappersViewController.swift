//
//  WrappersViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/25.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class WrappersViewController: ExampleViewController {
    @IBOutlet var pan: UITapGestureRecognizer!
    @IBOutlet weak var item: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var switcher: UISwitch!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var action: UIButton!
    @IBOutlet weak var alter: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textView1: UITextView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.date = Date(timeIntervalSince1970: 0)
        
        pan.rx.event.subscribe(onNext: {
            self.debug("UIGestureRecognizer event \($0.state.rawValue)")
        }).disposed(by: bag)
        
        item.rx.tap.bind {
            self.debug("UIBarButtonItem Tapped")
        }.disposed(by: bag)
        
        // 双向绑定
        let value = BehaviorRelay(value: 0)
        _ = segmentedControl.rx.value <-> value
        value.asObservable().subscribe(onNext: { (v) in
            self.debug("UISegmentedControl value \(v)")
        }).disposed(by: bag)
        
        slider.rx.value.subscribe(onNext: {
            self.debug("UISlider value \($0)")
        }).disposed(by: bag)
        
        // 双向绑定
        let switchV = BehaviorRelay(value: true)
        _ = switcher.rx.value <-> switchV
        switchV.asObservable().subscribe(onNext: {
            self.debug("UISwitch value \($0)")
        }).disposed(by: bag)
        switcher.rx.value.bind(to: activityIndicator.rx.isAnimating).disposed(by: bag)
        
        button.rx.tap.subscribe(onNext: {
            self.debug("UIButton Tapped")
        }).disposed(by: bag)
        
        let textV = BehaviorRelay(value: "")
        _ = textField.rx.textInput <-> textV
        textV.asObservable().subscribe(onNext: {
            self.debug("UITextField text \($0)")
        }).disposed(by: bag)
        
        let textV1 = BehaviorRelay<NSAttributedString?>(value: NSAttributedString(string: ""))
        _ = textField1.rx.attributedText <-> textV1
        textV1.asObservable().subscribe(onNext: {
            self.debug("UITextField attributedText \($0?.description ?? "")")
        }).disposed(by: bag)
        
        datePicker.rx.date.subscribe(onNext: {
            self.debug("UIDatePicker date \($0)")
        }).disposed(by: bag)
        
        action.rx.tap.subscribe(onNext: {
            let alter = UIAlertController(title: "ActionSheet", message: "这是ActionSheet", preferredStyle: .actionSheet)
            let action = UIAlertAction(title: "确定", style: .default, handler: nil)
            alter.addAction(action)
            self.present(alter, animated: true, completion: nil)
        }).disposed(by: bag)
        
        alter.rx.tap.subscribe(onNext: {
            let alter = UIAlertController(title: "Alter", message: "这是Alter", preferredStyle: .alert)
            let action = UIAlertAction(title: "确定", style: .default, handler: nil)
            alter.addAction(action)
            self.present(alter, animated: true, completion: nil)
        }).disposed(by: bag)
        
        let textViewV = BehaviorRelay(value: "")
        _ = textView.rx.textInput <-> textViewV
        textViewV.asObservable().subscribe(onNext: {
            self.debug("UITextView text \($0)")
        }).disposed(by: bag)
        
        let textViewV1 = BehaviorRelay<NSAttributedString?>(value: NSAttributedString(string: ""))
        _ = textView1.rx.attributedText <-> textViewV1
        textViewV1.asObservable().subscribe(onNext: {
            self.debug("UITextView attributedText \($0?.description ?? "")")
        }).disposed(by: bag)
    }
    
    func debug(_ param: String) {
        print(param)
        label.text = param
    }
}
