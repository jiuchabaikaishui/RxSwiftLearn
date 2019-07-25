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


class CompletableViewController: ExampleViewController, NVActivityIndicatorViewable {
    var bag = DisposeBag()
    
    @objc func firstAction(sender: UIButton) {
        startAnimating()
        cacheLocally().subscribe { (completable) in
            switch completable {
            case .completed:
                print("数据存储完成！")
            case .error(let error):
                print(error)
            }
            self.stopAnimating()
        }.disposed(by: bag)
    }
    @objc func secondAction(sender: UIButton) {
        startAnimating()
        cacheLocally().subscribe(onCompleted: {
            print("数据存储完成！")
            self.stopAnimating()
        }) { (error) in
            print(error)
            self.stopAnimating()
        }.disposed(by: bag)
    }
    
    func cacheLocally() -> Completable {
        return Completable.create { (completable) -> Disposable in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                let random = arc4random()%2
                if random == 0 {
                    // 模拟存储本地数据
                    completable(.completed)
                } else {
                    completable(.error(NSError(domain: "数据存储出错啦", code: 1111, userInfo: nil)))
                }
            })
            
            return Disposables.create()
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


class MaybeViewController: ExampleViewController, NVActivityIndicatorViewable {
    var bag = DisposeBag()
    
    @objc func firstAction(sender: UIButton) {
        startAnimating()
        generateString().subscribe { (maybe) in
            switch maybe {
            case .success(let element):
                print(element)
            case .error(let error):
                print(error)
            case .completed:
                print("我完成啦！")
            }
            self.stopAnimating()
        }.disposed(by: bag)
    }
    @objc func secondAction(sender: UIButton) {
        startAnimating()
        generateString().subscribe(onSuccess: { (element) in
            print(element)
            self.stopAnimating()
        }, onError: { (error) in
            print(error)
            self.stopAnimating()
        }) {
            print("我完成啦！")
            self.stopAnimating()
        }.disposed(by: bag)
    }
    
    func generateString() -> Maybe<String> {
        return Maybe<String>.create(subscribe: { (maybe) -> Disposable in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                let random = arc4random()%3
                switch random {
                case 0:
                    maybe(.success("我成功啦！"))
                case 1:
                    maybe(.completed)
                default:
                    maybe(.error(NSError(domain: "我失败啦！", code: 1111, userInfo: nil)))
                }
            })
            
            return Disposables.create()
        })
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


class ValuesViewController: ExampleViewController {
    @IBOutlet weak var a: UITextField!
    @IBOutlet weak var b: UITextField!
    @IBOutlet weak var c: UILabel!
    @IBOutlet weak var d: UILabel!
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ((Int(a.text ?? "") as Int?) ?? 0) + ((Int(b.text ?? "") as Int?) ?? 0) >= 0 {
            c.text = "c = \(Int(a.text!)! + Int(b.text!)!) is positive"
        }
        
        Observable.combineLatest(a.rx.text, b.rx.text, resultSelector: { ((Int($0!) as Int?) ?? 0) + ((Int($1!) as Int?) ?? 0) }).filter { $0 >= 0 }.map { "c = \($0) is positive"}.bind(to: d.rx.text).disposed(by: bag)
    }
}


class SimpleBindingViewController: ExampleViewController {
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var result: UILabel!
    var bag = DisposeBag()
    
    struct Prime {
        let value: Int
        var isPrime: Bool {
            get {
                if value < 2 {
                    return false
                }
                for i in 2..<value {
                    if value%i == 0 {
                        return false
                    }
                }
                
                return true
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        number.rx.text.map { Prime(value: Int($0 ?? "") as Int? ?? 0) }.map { "\($0.value) \($0.isPrime ? "是" : "不是")素数！" }.bind(to: result.rx.text).disposed(by: bag)
    }
}


class InputIValidationViewController: ExampleViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var error: UILabel!
    var bag = DisposeBag()
    
    enum Availability {
        case available(message: String)
        case taken(message: String)
        case invalid(message: String)
        case pending(message: String)
        
        var message: String {
            switch self {
            case .available(let message),
                 .taken(let message),
                 .invalid(let message),
                 .pending(let message):
                
                return message
            }
        }
    }
    struct API {
        static func usernameAvailable(_ username: String) -> Observable<Bool> {
            return Observable<Bool>.create({ (observer) -> Disposable in
                DispatchQueue.global().async {
                    Thread.sleep(forTimeInterval: TimeInterval(2 + arc4random()%3))
                    DispatchQueue.main.async {
                        if arc4random()%2 == 0 {
                            observer.onNext(false)
                        } else {
                            observer.onNext(true)
                        }
                    }
                }
                
                return Disposables.create()
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        name.rx.text.map { (n) -> Observable<Availability> in
            guard let username = n, !username.isEmpty else {
                return Observable.just(.invalid(message: "用户名不能为空."))
            }
            
            let loadingValue = Availability.pending(message: "检查可用性……")
            return API.usernameAvailable(username).map({ (available) -> Availability in
                if available {
                    return .available(message: "用户名有效")
                } else {
                    return .invalid(message: "用户名无效")
                }
            }).startWith(loadingValue)
            }.switchLatest().subscribe(onNext: { [unowned self] (validity) in
                self.error.text = validity.message
            }).disposed(by: bag)
    }
}
