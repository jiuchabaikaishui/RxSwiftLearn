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
import CoreLocation


class BaseViewController: UIViewController {
    var bag = DisposeBag()
    
    deinit {
        print("\(self)销毁了！")
    }
}
class ExampleViewController: BaseViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ((Int(a.text ?? "") as Int?) ?? 0) + ((Int(b.text ?? "") as Int?) ?? 0) >= 0 {
            c.text = "c = \(Int(a.text!)! + Int(b.text!)!) is positive"
        }
        
        Observable.combineLatest(a.rx.text.orEmpty.map({ Int($0) ?? 0 }), b.rx.text.orEmpty.map({ Int($0) ?? 0 })) { $0 + $1 }.filter {  $0 >= 0 }.map { "c = \($0) is positive" }.bind(to: d.rx.text).disposed(by: bag)
//        Observable.combineLatest(a.rx.text, b.rx.text, resultSelector: { ((Int($0!) as Int?) ?? 0) + ((Int($1!) as Int?) ?? 0) }).filter { $0 >= 0 }.map { "c = \($0) is positive"}.bind(to: d.rx.text).disposed(by: bag)
    }
}


class SimpleBindingViewController: ExampleViewController {
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var result: UILabel!
    
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
    func wolframAlphaIsPrime(_ value: Int) -> Observable<Prime> {
        return Observable<Prime>.create({ (observer) -> Disposable in
            observer.onNext(Prime(value: value))
            observer.onCompleted()
            
            return Disposables.create()
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        number.rx.text.map { [unowned self] in self.wolframAlphaIsPrime( Int($0 ?? "") as Int? ?? 0) }.concat().map { "\($0.value) \($0.isPrime ? "是" : "不是")素数！" }.bind(to: result.rx.text).disposed(by: bag)
    }
}


class InputIValidationViewController: ExampleViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var error: UILabel!
    
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


class NumbersViewController: ExampleViewController {
    @IBOutlet weak var number1: UITextField!
    @IBOutlet weak var number2: UITextField!
    @IBOutlet weak var number3: UITextField!
    @IBOutlet weak var result: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable.combineLatest(number1.rx.text.orEmpty, number2.rx.text.orEmpty, number3.rx.text.orEmpty) { (value1, value2, value3) -> Int in
            return (Int(value1) ?? 0) + (Int(value2) ?? 0) + (Int(value3) ?? 0)
            }.map { $0.description }.bind(to: result.rx.text).disposed(by: bag)
    }
}


class ValidViewController: ExampleViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var usernameValid: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordValid: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let minUsernameLength = 6
        let minPasswordLength = 6
        usernameValid.text = "用户名至少\(minUsernameLength)个字符……"
        passwordValid.text = "密码至少\(minUsernameLength)个字符……"
        
        let usernameV = username.rx.text.orEmpty.map { $0.count >= minUsernameLength }.share(replay: 1)
        let passwordV = password.rx.text.orEmpty.map { $0.count >= minPasswordLength }.share(replay: 1)
        let buttonV = Observable.combineLatest(usernameV, passwordV) { $0 && $1 }.share(replay: 1)
        
        usernameV.bind(to: password.rx.isEnabled).disposed(by: bag)
        usernameV.bind(to: usernameValid.rx.isHidden).disposed(by: bag)
        passwordV.bind(to: passwordValid.rx.isHidden).disposed(by: bag)
        buttonV.bind(to: button.rx.isEnabled).disposed(by: bag)
        button.rx.tap.subscribe {[unowned self] (_) in
            let alert = UIAlertController(title: "提示", message: "登录成功！", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }.disposed(by: bag)
    }
}


class LocationViewController: ExampleViewController {
    @IBOutlet weak var noGeolocationView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button1: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(noGeolocationView)
        noGeolocationView.snp.makeConstraints { (maker) in
            maker.left.top.right.bottom.equalTo(view)
        }
        
        let service = GeoLocationService.instance
        
        service.authorized.drive(noGeolocationView.rx.isHidden).disposed(by: bag)
        
        service.location.drive(label.rx.coordinate).disposed(by: bag)
        
        button.rx.tap.bind {[unowned self] in self.openAppPreferences() }.disposed(by: bag)
        
        button1.rx.tap.bind {[unowned self] in self.openAppPreferences() }.disposed(by: bag)
    }
    
    private func openAppPreferences() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}


class SignupObservableViewController: ExampleViewController {
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    @IBOutlet weak var repeatOutlet: UITextField!
    @IBOutlet weak var repeatValidationOutlet: UILabel!
    @IBOutlet weak var signupOutlet: UIButton!
    @IBOutlet weak var signingupOutlet: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vm = SignupObservableVM(input: (username: usernameOutlet.rx.text.orEmpty.asObservable(), password: passwordOutlet.rx.text.orEmpty.asObservable(), repeatedPassword: repeatOutlet.rx.text.orEmpty.asObservable(), loginTaps: signupOutlet.rx.tap.asObservable()), dependency: (API: GitHubDefaultAPI.shareApi, service: GitHubDefaultValidationService(GitHubDefaultAPI.shareApi)))
        
        vm.signupEnabled.subscribe(onNext: { (valid) in
            self.signupOutlet.isEnabled = valid
            self.signupOutlet.alpha = valid ? 1.0 : 0.5
        }).disposed(by: bag)
        
        vm.validatedUsername.bind(to: usernameValidationOutlet.rx.validationResult).disposed(by: bag)
        
        vm.validatedPassword.bind(to: passwordValidationOutlet.rx.validationResult).disposed(by: bag)
        
        vm.validatedRepeatedPassword.bind(to: repeatValidationOutlet.rx.validationResult).disposed(by: bag)
        
        vm.signingIn.bind(to: signingupOutlet.rx.isAnimating).disposed(by: bag)
        
        vm.signedIn.subscribe(onNext: { (signed) in
            print("用户登录\(signed ? "成功" : "失败")")
        }).disposed(by: bag)
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { (tap) in
            self.view.endEditing(true)
        }).disposed(by: bag)
        view.addGestureRecognizer(tap)
    }
}


class SignupDriverViewController: ExampleViewController {
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    @IBOutlet weak var repeatOutlet: UITextField!
    @IBOutlet weak var repeatValidationOutlet: UILabel!
    @IBOutlet weak var signupOutlet: UIButton!
    @IBOutlet weak var signingupOutlet: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vm = SignupDriverVM(input: (username: usernameOutlet.rx.text.orEmpty.asDriver(), password: passwordOutlet.rx.text.orEmpty.asDriver(), repeatedPassword: repeatOutlet.rx.text.orEmpty.asDriver(), loginTaps: signupOutlet.rx.tap.asSignal()), depandency: (API: GitHubDefaultAPI.shareApi, service: GitHubDefaultValidationService(GitHubDefaultAPI.shareApi)))
        
        vm.signupEnabled.drive(onNext: {
            self.signupOutlet.isEnabled = $0
            self.signupOutlet.alpha = $0 ? 1.0 : 0.5
        }).disposed(by: bag)
        
        vm.usernameValidated.drive(usernameValidationOutlet.rx.validationResult).disposed(by: bag)
        vm.passwordValidated.drive(passwordValidationOutlet.rx.validationResult).disposed(by: bag)
        vm.repeatedPasswordValidated.drive(repeatValidationOutlet.rx.validationResult).disposed(by: bag)
        
        vm.signingIn.drive(signingupOutlet.rx.isAnimating).disposed(by: bag)
        
        vm.signedIn.drive(onNext: {
            print("用户登录\($0 ? "成功" : "失败")")
        }).disposed(by: bag)
    }
}

struct User {
    var name: String
    var age: Int
}
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
        
        let user = User(name: "张三", age: 4)
        let userDefault = UserDefaults.standard
        userDefault.set(user, forKey: "User")
        userDefault.synchronize()
        let u = userDefault.value(forKey: "User")
        print(u as! User);
        
        datePicker.rx.date.subscribe(onNext: {
            self.debug("UIDatePicker date \($0)")
        }).disposed(by: bag)
        
        action.rx.tap.subscribe(onNext: {
            let alter = UIAlertController(title: "ActionSheet", message: "这是ActionSheet", preferredStyle: .actionSheet)
            let action = UIAlertAction(title: "确定", style: .default, handler: nil)
            alter.addAction(action)
        }).disposed(by: bag)
        
        alter.rx.tap.subscribe(onNext: {
            let alter = UIAlertController(title: "Alter", message: "这是Alter", preferredStyle: .alert)
            let action = UIAlertAction(title: "确定", style: .default, handler: nil)
            alter.addAction(action)
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

