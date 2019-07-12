//
//  ExampleViewController.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/7/12.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let title = self.title {
            self.title = title + "示例"
        }
        
        guard let _ = self.view?.backgroundColor else {
            self.view.backgroundColor = UIColor.white
            return
        }
    }
}

class BandingViewController: ExampleViewController {
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var greetingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = Observable.combineLatest(firstName.rx.text.orEmpty, lastName.rx.text.orEmpty) { $0 + " " + $1 }.map { "Greetings, \($0)" }.bind(to: greetingLabel.rx.text)
    }
}

class DisposeBagViewController: ExampleViewController {
    var disposeBag = DisposeBag()
    
    func intObservable(queue: DispatchQueue, milliseconds: Int) -> Observable<Int> {
        return Observable<Int>.create { (observer) -> Disposable in
            var element = 0
            func next(work: @escaping (_ value: Int) -> ()) {
                work(element)
                queue.asyncAfter(deadline: DispatchTime.now() + .milliseconds(milliseconds), execute: {
                    element += 1
                    next(work: work)
                })
            }
            next(work: { (value) in
                observer.onNext(value)
            })
            return Disposables.create()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        work()
    }
    func work() {
        intObservable(queue: DispatchQueue.global(), milliseconds: 300).subscribe { (event) in
            print("序列1：\(event)")
            }.disposed(by: DisposeBag())//立即清理
        Observable<Int>.interval(.milliseconds(300), scheduler: SerialDispatchQueueScheduler(qos: .default)).subscribe { (event) in
            print("序列2：\(event)")
            }.disposed(by: self.disposeBag)//延迟清理
        Observable<Int>.interval(.milliseconds(300), scheduler: SerialDispatchQueueScheduler(qos: .default)).subscribe { (event) in
            print("序列3：\(event)")
            }.disposed(by: self.disposeBag)//延迟清理
    }
    
    @IBAction func clearAction(_ sender: UIButton) {
        if sender.isSelected {
            work()
        } else {
            disposeBag = DisposeBag()
        }
        sender.isSelected = !sender.isSelected
    }
}

class TakeuntilViewController: ExampleViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = Observable<Int>.interval(.milliseconds(300), scheduler: SerialDispatchQueueScheduler(qos: .default)).takeUntil(self.rx.deallocated).subscribe { (event) in
            print(event)
        }
    }
}

class ImplicitViewController: ExampleViewController {
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        work()
    }
    func work() {
        Observable<Int>.interval(.milliseconds(300), scheduler: ConcurrentDispatchQueueScheduler(qos: .default)).subscribe({ (event) in
            print("任务1")
            Thread.sleep(forTimeInterval: 1)
            print("任务2")
        }).disposed(by: self.disposeBag)
    }
    @IBAction func clearAction(_ sender: UIButton) {
        if sender.isSelected {
            work()
        } else {
            disposeBag = DisposeBag()
        }
        sender.isSelected = !sender.isSelected
    }
}
