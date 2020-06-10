//
//  CalculatorViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/25.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class CalculatorViewController: ExampleViewController {
    @IBOutlet weak var signLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var changeSignButton: UIButton!
    @IBOutlet weak var percentButton: UIButton!
    
    @IBOutlet weak var equalButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var divideButton: UIButton!
    
    @IBOutlet weak var dotButton: UIButton!
    @IBOutlet weak var zeroButton: UIButton!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 所有操作的Observable<CalculatorCommand>数组
        let events: [Observable<CalculatorCommand>] = [
            clearButton.rx.tap.map({ CalculatorCommand.clear }),
            changeSignButton.rx.tap.map({ CalculatorCommand.changeSign }),
            percentButton.rx.tap.map({ CalculatorCommand.percent }),
            equalButton.rx.tap.map({ CalculatorCommand.equal }),
            plusButton.rx.tap.map({ CalculatorCommand.operation(Operator.addition) }),
            minusButton.rx.tap.map({ CalculatorCommand.operation(Operator.subtruction) }),
            multiplyButton.rx.tap.map({ CalculatorCommand.operation(Operator.multiplication) }),
            divideButton.rx.tap.map({ CalculatorCommand.operation(Operator.division) }),
            dotButton.rx.tap.map({ CalculatorCommand.addDoc }),
            zeroButton.rx.tap.map({ CalculatorCommand.addNumber("0") }),
            oneButton.rx.tap.map({ CalculatorCommand.addNumber("1") }),
            twoButton.rx.tap.map({ CalculatorCommand.addNumber("2") }),
            threeButton.rx.tap.map({ CalculatorCommand.addNumber("3") }),
            fourButton.rx.tap.map({ CalculatorCommand.addNumber("4") }),
            fiveButton.rx.tap.map({ CalculatorCommand.addNumber("5") }),
            sixButton.rx.tap.map({ CalculatorCommand.addNumber("6") }),
            sevenButton.rx.tap.map({ CalculatorCommand.addNumber("7") }),
            eightButton.rx.tap.map({ CalculatorCommand.addNumber("8") }),
            nineButton.rx.tap.map({ CalculatorCommand.addNumber("9") })
        ]
        
        /// 初始状态
        let initState = CalculatorState.inital
        /// 操作线程
        let scheduler = MainScheduler.instance
        /// 绑定
        Observable.deferred({
            Observable.merge(events)
                .scan(initState) { $0.reduce(command: $1) }
                .subscribeOn(MainScheduler.instance)
                .startWith(initState)
                .observeOn(scheduler)
        }).subscribe(onNext: { (state) in
            self.signLabel.text = state.sign
            self.resultLabel.text = state.screen
        }).disposed(by: bag)
    }
}
