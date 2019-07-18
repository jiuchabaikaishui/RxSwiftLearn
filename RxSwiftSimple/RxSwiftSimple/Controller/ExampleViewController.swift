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
import SnapKit
import NVActivityIndicatorView

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
class KVOViewController: ExampleViewController {
    @objc dynamic weak var viewT: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v = UIView()
        v.backgroundColor = UIColor.cyan
        view.addSubview(v)
        viewT = v
        viewT?.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(44.0)
            maker.center.equalTo(view).offset(10.0)
        }
        
        _ = self.rx.observe(CGPoint.self, "view.center").subscribe({ (e) in
            print(e)
        })
        
        _ = self.rx.observeWeakly(CGPoint.self, "viewT.center").subscribe { (e) in
            print(e)
        }
    }
}
class HTTPViewController: ExampleViewController, NVActivityIndicatorViewable {
    @objc func buttonAction(sender: UIButton) {
        startAnimating()
        let _ = URLSession.shared.rx.response(request: URLRequest.init(url: URL(string: "https://ditu.amap.com/service/regeo?longitude=121.04925573429551&latitude=31.315590522490712")!)).debug("my request").flatMap({ (response: HTTPURLResponse, data: Data) -> Observable<String> in
            if 200 ..< 300 ~= response.statusCode {
                return Observable<String>.create({ (observer) -> Disposable in
                    observer.onNext(String(data: data, encoding: .utf8) ?? "")
                    observer.onCompleted()
                    
                    return Disposables.create()
                })
            }
            else {
                return Observable.error(NSError(domain: "xxx", code: 111, userInfo: nil))
            }
        }).subscribe({ (event) in
            if let data = event.element?.data(using: .utf8) {
                do {
                    print(try JSONSerialization.jsonObject(with: data, options: .allowFragments))
                } catch {
                    print("数据解析失败！")
                }
            }
            self.stopAnimating()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(2), execute: {
                //                activityIndicatorView.stopAnimating()
            })
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .system)
        button.setTitle("请求", for: .normal)
        button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpOutside)
        view.addSubview(button)
        button.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(self.view.safeAreaInsets.bottom)
            maker.centerX.equalTo(self.view)
            maker.width.height.equalTo(50)
        }
        
    }
}
