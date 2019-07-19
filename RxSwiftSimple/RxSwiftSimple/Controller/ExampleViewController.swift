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
    deinit {
        print("\(self)销毁了！")
    }
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
    let bag = DisposeBag()
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var greetingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Observable.combineLatest(firstName.rx.text.orEmpty, lastName.rx.text.orEmpty) { $0 + " " + $1 }.map { "Greetings, \($0)" }.bind(to: greetingLabel.rx.text).disposed(by: bag)
    }
}


class DisposeBagViewController: ExampleViewController {
    var disposeBag = DisposeBag()
    
    func intObservable(queue: DispatchQueue, milliseconds: Int) -> Observable<Int> {
        return Observable<Int>.create { (observer) -> Disposable in
            var element = 0
            observer.onNext(element)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(milliseconds), execute: {
                element += 1
                observer.onNext(element)
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
            }.dispose()//立即清理
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
    let bag = DisposeBag()
    
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
        
        rx.observe(CGPoint.self, "view.center", retainSelf: false).subscribe { (e) in
            print(e)
        }.disposed(by: bag)
        
        rx.observeWeakly(CGPoint.self, "viewT.center").subscribe { (e) in
            print(e)
        }.disposed(by: bag)
    }
}


class HTTPViewController: ExampleViewController, NVActivityIndicatorViewable {
    var bag = DisposeBag()
    let req = URLSession.shared.rx.response(request: URLRequest.init(url: URL(string: "https://ditu.amap.com/service/regeo?longitude=121.04925573429551&latitude=31.315590522490712")!)).debug("my request").flatMap({ (response: HTTPURLResponse, data: Data) -> Observable<Any> in
        if 200 ..< 300 ~= response.statusCode {
            return Observable<Any>.create({ (observer) -> Disposable in
                do {
                    observer.onNext(try JSONSerialization.jsonObject(with: data, options: .allowFragments))
                } catch {
                    observer.onError(NSError(domain: "数据解析失败！", code: 1111, userInfo: nil))
                    print("数据解析失败！")
                }
                
                return Disposables.create()
            })
        }
        else {
            return Observable.error(NSError(domain: "网络请求失败！", code: 2222, userInfo: nil))
        }
    }).observeOn(MainScheduler.instance).replay(1).refCount()
    
    @objc func buttonAction(sender: UIButton) {
        startAnimating()
        req.subscribe({ (event) in
            print(event.element ?? "没有数据！")
            self.stopAnimating()
            self.bag = DisposeBag()
        }).disposed(by: bag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .system)
        button.setTitle("请求", for: .normal)
        button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            maker.centerX.equalTo(self.view)
            maker.width.height.equalTo(50)
        }
    }
}


class SingleViewController: ExampleViewController, NVActivityIndicatorViewable {
    var bag = DisposeBag()
    
    @objc func firstAction(sender: UIButton) {
        startAnimating()
        getReq("ReactiveX/RxSwift").subscribe({ (event) in
            switch event {
            case .success(let json):
                print("JSON: ", json)
            case .error(let error):
                print("Error: ", error)
            }
            self.stopAnimating()
        }).disposed(by: bag)
    }
    @objc func secondAction(sender: UIButton) {
        startAnimating()
        getReq("ReactiveX/RxSwift").subscribe(onSuccess: { (json) in
            print("JSON: ", json)
            self.stopAnimating()
        }, onError: { (error) in
            print("Error: ", error)
            self.stopAnimating()
        }).disposed(by: bag)
    }
    
    func getReq(_ repo: String) -> Single<Any> {
        return Single<Any>.create { (single) -> Disposable in
            let tast = URLSession.shared.dataTask(with: URL(string: "https://api.github.com/repos/\(repo)")!, completionHandler: { (data, _, error) in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else {
                    single(.error(NSError(domain: "数据无法解析", code: 1111, userInfo: nil)))
                    return
                }
                
                single(.success(json))
            })
            
            tast.resume()
            
            return Disposables.create {
                tast.cancel()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstButton = UIButton(type: .system)
        firstButton.setTitle("方法一", for: .normal)
        firstButton.addTarget(self, action: #selector(firstAction(sender:)), for: .touchUpInside)
        view.addSubview(firstButton)
        firstButton.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            maker.height.equalTo(50)
            maker.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(8.0)
            maker.right.equalTo(self.view.snp.centerX).offset(-8.0)
        }
        
        let secondButton = UIButton(type: .system)
        secondButton.setTitle("方法二", for: .normal)
        secondButton.addTarget(self, action: #selector(secondAction(sender:)), for: .touchUpInside)
        view.addSubview(secondButton)
        secondButton.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            maker.height.equalTo(50)
            maker.left.equalTo(self.view.snp.centerX).offset(8.0)
            maker.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-8.0)
        }
    }
}
