//
//  ViewModels.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/7/30.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


typealias SelectedAction = (_ controller: UIViewController, _ tableView: UITableView, _ indexPath: IndexPath) -> ()
struct TableViewRowVM {
    var title = ""
    var detail = ""
    var selected = false
    var pushed = false
    var selectedAction: SelectedAction? = nil
}
struct TableViewSectionVM {
    var title = ""
    var rows = [TableViewRowVM]()
}
struct ViewControllerVM {
    static var debugSubscribe: Disposable? = nil
    static func myInterval(_ interval: DispatchTimeInterval) -> Observable<Int> {
        return Observable.create({ (observer) -> Disposable in
            print("Subscribed")
            let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            timer.schedule(deadline: DispatchTime.now() + interval, repeating: interval)
            let cancel = Disposables.create {
                print("Disposed")
                timer.cancel()
            }
            
            var next = 0
            timer.setEventHandler(handler: {
                if cancel.isDisposed {
                    return
                }
                observer.onNext(next)
                next += 1
            })
            timer.resume()
            
            return cancel
        })
    }
    let data = [
        TableViewSectionVM(title: "简介", rows: [
            TableViewRowVM(title: "用法", detail: "从GitHub仓库的搜索", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToUsage", sender: tableView.cellForRow(at: indexPath))
            })
            ]),
        TableViewSectionVM(title: "为何", rows: [
            TableViewRowVM(title: "绑定", detail: "从GitHub仓库的搜索", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToBanding", sender: tableView.cellForRow(at: indexPath))
            })
            ]),
        TableViewSectionVM(title: "基础", rows: [
            TableViewRowVM(title: "Disposing", detail: "观察的序列终止的一种方法。想要释放分配用于计算即将到来的元素的所有资源时，可以调用subscribe操作返回的Disposable的dispose操作。", selected: true, pushed: false, selectedAction: { controller, tableView, indexPath in
                let scheduler = SerialDispatchQueueScheduler(qos: .default)
                let subscription = Observable<Int>.interval(.milliseconds(300), scheduler: scheduler).subscribe { (event) in
                    print(event)
                }
                
                Thread.sleep(forTimeInterval: 2)
                
                print("dispose")
                subscription.dispose()
            }),
            TableViewRowVM(title: "Dispose Bags", detail: "Dispose Bags用于返回类似ARC行为的RX。当DisposeBag被销毁时，它将调用每个添加的disposables的dispose。", selected: true, pushed: true, selectedAction: { controller, tableView, indexPath in
                controller.performSegue(withIdentifier: "MainToDisposeBag", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "Take until", detail: "使用takeUntil操作在dealloc中自动清理订阅。", selected: true, pushed: true, selectedAction: { controller, tableView, indexPath in
                let dis = TakeuntilViewController()
                if let title = (controller as? ViewController)?.vm.rowVM(indexPath: indexPath)?.title {
                    dis.title = title
                }
                
                controller.navigationController?.pushViewController(dis, animated: true)
            }),
            TableViewRowVM(title: "隐含的Observable保证", detail: "一个事件未完成时不能发送第二个事件。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToImplicit", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "just", detail: "RxSwift提供了一个just方法，该方法创建一个在订阅时返回一个元素的序列。", selected: true, pushed: false, selectedAction: { (controller, tableView, indexPath) in
                func myJust<E>(_ element: E) -> Observable<E> {
                    return Observable<E>.create({ (observer) -> Disposable in
                        observer.onNext(element)
                        observer.onCompleted()
                        
                        return Disposables.create()
                    })
                }
                
                let _ = myJust(0).subscribe({ (n) in
                    print(n)
                })
            }),
            TableViewRowVM(title: "create", detail: "Swift使用create闭包轻松实现subscribe方法。它接受一个参数observer，并返回disposable。", selected: true, pushed: false, selectedAction: { (controller, tableView, indexPath) in
                func myFrom<E>(_ sequese: [E]) -> Observable<E> {
                    return Observable.create({ (observer) -> Disposable in
                        for element in sequese {
                            observer.onNext(element)
                        }
                        observer.onCompleted()
                        
                        return Disposables.create()
                    })
                }
                
                let stringCounter = myFrom(["first", "second"])
                print("Started ----")
                
                let _ = stringCounter.subscribe({ (n) in
                    print(n)
                })
                print("----")
                
                let _ = stringCounter.subscribe({ (n) in
                    print(n)
                })
                print("Ended ----")
            }),
            TableViewRowVM(title: "创建Observable执行工作", detail: "创建前面使用的interval操作符，这相当于调度队列调度程序的实际实现。", selected: true, pushed: false, selectedAction: { (controller, tableView, indexPath) in
                let counter = myInterval(.milliseconds(100))
                print("Started ----")
                let subscription = counter.subscribe({ (n) in
                    print(n)
                })
                Thread.sleep(forTimeInterval: 0.5)
                subscription.dispose()
                print("Ended ----")
                
                let counter1 = myInterval(.milliseconds(100))
                print("Started ----")
                let subscription1 = counter1.subscribe({ (n) in
                    print("First \(n)")
                })
                let subscription2 = counter1.subscribe({ (n) in
                    print("Second \(n)")
                })
                Thread.sleep(forTimeInterval: 0.5)
                subscription1.dispose()
                Thread.sleep(forTimeInterval: 0.5)
                subscription2.dispose()
                print("Ended ----")
            }),
            TableViewRowVM(title: "共享订阅和share操作符", detail: "希望多个观察者仅从一个订阅共享事件（元素）使用share操作符。", selected: true, pushed: false, selectedAction: { (controller, tableView, indexPath) in
                let counter = myInterval(.milliseconds(100)).replay(1).refCount()
                
                print("Started ----")
                let subscription1 = counter.subscribe({ (n) in
                    print("First \(n)")
                })
                let subscription2 = counter.subscribe({ (n) in
                    print("Second \(n)")
                })
                Thread.sleep(forTimeInterval: 0.5)
                subscription1.dispose()
                Thread.sleep(forTimeInterval: 0.5)
                subscription2.dispose()
                print("Ended ----")
            }),
            TableViewRowVM(title: "自定义操作符", detail: "实现未优化的map操作符。", selected: true, pushed: false, selectedAction: { (controller, tableView, indexPath) in
                let subscription = myInterval(.milliseconds(100)).myMap(transform: { (e) -> String in
                    return "This is simply \(e)"
                }).subscribe({ (n) in
                    print(n)
                })
                
                Thread.sleep(forTimeInterval: 0.5)
                subscription.dispose()
            }),
            TableViewRowVM(title: "debug", detail: "debug运算符将所有事件打印到标准输出，也可以添加标记这些事件。", selected: true, pushed: false, selectedAction: { (controller, tableView, indexPath) in
                let subscription = myInterval(.milliseconds(100)).debug("my probe").map({ (e) in
                    return "This is simply \(e)"
                }).subscribe({ (n) in
                    print(n)
                })
                
                Thread.sleep(forTimeInterval: 0.5)
                subscription.dispose()
            }),
            TableViewRowVM(title: "自定义deBug操作符", detail: "实现与上面自定义操作符类似。", selected: true, pushed: false, selectedAction: { (controller, tableView, indexPath) in
                let subscription = myInterval(.milliseconds(100)).myDebug("my probe").map({ (e) in
                    return "This is simply \(e)"
                }).subscribe({ (n) in
                    print(n)
                })
                
                Thread.sleep(forTimeInterval: 0.5)
                subscription.dispose()
            }),
            TableViewRowVM(title: "调试内存泄漏", detail: "在调试模式下，Rx在全局变量Resources.total中跟踪所有的已分配资源。如果想要一些资源泄漏检测逻辑，最简单的方法是定期打印RxSwift.Resources.total。", selected: true, pushed: false, selectedAction: { (controller, tableView, indexPath) in
                if let subscribe = ViewControllerVM.debugSubscribe {
                    subscribe.dispose()
                    ViewControllerVM.debugSubscribe = nil
                } else {
                    ViewControllerVM.debugSubscribe = Observable<Int>.interval(.seconds(2), scheduler: MainScheduler.instance).subscribe { (_) in
                        print("Resource count \(RxSwift.Resources.total)")
                    }
                }
            }),
            TableViewRowVM(title: "KVO", detail: "RxSwift支持rx.observe和rx.observeWeakly两种KVO方式，rx.observe性能高，因为它只是一个KVO机制的简单包装，使用场景有限。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                let dis = KVOViewController()
                if let title = (controller as? ViewController)?.vm.rowVM(indexPath: indexPath)?.title {
                    dis.title = title
                }
                
                controller.navigationController?.pushViewController(dis, animated: true)
            }),
            TableViewRowVM(title: "发送HTTP请求", detail: "构建http请求，默认情况下，URLSession不会在MainScheduler中返回结果。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                let dis = HTTPViewController()
                if let title = (controller as? ViewController)?.vm.rowVM(indexPath: indexPath)?.title {
                    dis.title = title
                }
                
                controller.navigationController?.pushViewController(dis, animated: true)
            })
            ]),
        TableViewSectionVM(title: "特征", rows: [
            TableViewRowVM(title: "Single", detail: "Single是Observable的变体，它总是保证发出单个元素或错误，而不是发出一系列元素。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                let dis = SingleViewController()
                if let title = (controller as? ViewController)?.vm.rowVM(indexPath: indexPath)?.title {
                    dis.title = title
                }
                
                controller.navigationController?.pushViewController(dis, animated: true)
            }),
            TableViewRowVM(title: "Completable", detail: "Completable是Observable的变体，只能完成或发出错误。保证不发出任何元素。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                let dis = CompletableViewController()
                if let title = (controller as? ViewController)?.vm.rowVM(indexPath: indexPath)?.title {
                    dis.title = title
                }
                
                controller.navigationController?.pushViewController(dis, animated: true)
            }),
            TableViewRowVM(title: "Maybe", detail: "Maybe是Observable的变体，它位于Single和Completable之间。它既可以发出单个元素，也可以在不发出元素的情况下完成，或者发出错误。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                let dis = MaybeViewController()
                if let title = (controller as? ViewController)?.vm.rowVM(indexPath: indexPath)?.title {
                    dis.title = title
                }
                
                controller.navigationController?.pushViewController(dis, animated: true)
            })
            ]),
        TableViewSectionVM(title: "Schedulers", rows: [
            TableViewRowVM(title: "observeOn", detail: "要在不同的Schedulers上执行工作，使用observeOn(scheduler)操作符。", selected: true, pushed: false, selectedAction: { (controller, tableView, indexPath) in
                let disposable = Observable<Int>.create({ (observer) -> Disposable in
                    observer.onNext((1))
                    return Disposables.create()
                }).observeOn(MainScheduler.instance).map({ (n) -> Int in
                    print(Thread.current)
                    print(n)
                    
                    return n + 1
                }).observeOn(ConcurrentDispatchQueueScheduler(qos: .background)).map({ (n) -> Int in
                    print(Thread.current)
                    print(n)
                    
                    return n + 1
                }).subscribe({ (n) in
                    print(Thread.current)
                    print(n)
                })
                
                Thread.sleep(forTimeInterval: 1)
                disposable.dispose()
            }),
            TableViewRowVM(title: "subscribeOn", detail: "要在特定scheduler上启动序列生成元素（subscribe方法）并调用dispose，请使用subscribeOn(scheduler)。", selected: true, pushed: false, selectedAction: { (controller, tableView, indexPath) in
                let disposable = Observable<Void>.create({ (observer) -> Disposable in
                    observer.onNext(())
                    return Disposables.create()
                }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background)).subscribe({ (e) in
                    print(Thread.current)
                })
                
                Thread.sleep(forTimeInterval: 1)
                disposable.dispose()
            })
            ]),
        TableViewSectionVM(title: "示例", rows: [
            TableViewRowVM(title: "绑定值", detail: "在这个示例中体会命令式与响应式编程的差异。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToValues", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "简单UI绑定", detail: "一个简单的UI绑定示例。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToSimpleBinding", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "自动输入验证", detail: "此示例包含具有进度通知的复杂异步UI验证逻辑。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToInputIValidation", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "数字相加", detail: "绑定。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToNumbers", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "简单验证", detail: "绑定。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToValid", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "定位", detail: "绑定。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToLoction", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "GitHub注册", detail: "绑定。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToSignupObservable", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "GitHub登录", detail: "绑定。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToSignupDriver", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "GitHub登录", detail: "绑定。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToWrappers", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "计算器", detail: "绑定。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToCalculator", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "图片采集", detail: "绑定。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToImagePicker", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "PickerView", detail: "绑定。", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToPickerView", sender: tableView.cellForRow(at: indexPath))
            })
        ])
    ]
    
    func rowVM(indexPath: IndexPath) -> TableViewRowVM? {
        if indexPath.section < data.count {
            let section = data[indexPath.section]
            if indexPath.row < section.rows.count {
                return section.rows[indexPath.row]
            }
        }
        
        return nil
    }
}

class SignupObservableVM {
    // 用户名有效的序列
    let validatedUsername: Observable<ValidationResult>
    // 密码有效的序列
    let validatedPassword: Observable<ValidationResult>
    // 重复密码有效的序列
    let validatedRepeatedPassword: Observable<ValidationResult>
    // 允许登录
    let signupEnabled: Observable<Bool>
    // 登录
    let signedIn: Observable<Bool>
    // 登录中
    let signingIn: Observable<Bool>
    
    init(input: (username: Observable<String>, password: Observable<String>, repeatedPassword: Observable<String>, loginTaps: Observable<Void>), dependency: (API: GithubApi, service: GitHubValidationService)) {
        let api = dependency.API
        let service = dependency.service
        
        validatedUsername = input.username.distinctUntilChanged().flatMapLatest({ (name) in
            return service.validateUsername(name).observeOn(MainScheduler.instance).catchErrorJustReturn(.failed(message: "服务器报错"))
        })
        
        validatedPassword = input.password.map({ (password) in
            return service.validatePassword(password)
        }).share(replay: 1)
        
        validatedRepeatedPassword = Observable.combineLatest(input.password, input.repeatedPassword, resultSelector: service.validateRepeatedPassword).share(replay: 1)
        
        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asObservable()
        
        let up = Observable.combineLatest(input.username, input.password) { (username: $0, password: $1) }
        
        signedIn = input.loginTaps.withLatestFrom(up).flatMapLatest({ (pair) in
            return api.signup(pair.username, password: pair.password).observeOn(MainScheduler.instance).catchErrorJustReturn(false).trackActivity(signingIn)
        }).flatMapLatest({ (loggedIn) -> Observable<Bool> in
            let message = loggedIn ? "登录GitHub" : "GitHub登录失败"
            return DefaultWireFrame().promptFor("提示", message: message, cancelAction: "确定", actions: ["否"]).map({ _ in loggedIn })
        }).share(replay: 1)
        
        signupEnabled = Observable.combineLatest(validatedUsername, validatedPassword, validatedRepeatedPassword, self.signingIn, resultSelector: { (un, pd, repd, sign) in
            un.isValidate && pd.isValidate && repd.isValidate && !sign
        }).distinctUntilChanged().share(replay: 1)
    }
}


class SignupDriverVM {
    let usernameValidated: Driver<ValidationResult>
    let passwordValidated: Driver<ValidationResult>
    let repeatedPasswordValidated: Driver<ValidationResult>
    
    let signupEnabled: Driver<Bool>
    let signedIn: Driver<Bool>
    let signingIn: Driver<Bool>
    
    init(input: (username: Driver<String>, password: Driver<String>, repeatedPassword: Driver<String>, loginTaps: Signal<()>), depandency: (API: GithubApi, service: GitHubValidationService)) {
        usernameValidated = input.username.flatMapLatest({
            return depandency.service.validateUsername($0).asDriver(onErrorJustReturn: .failed(message: "连接服务器失败"))
        })
        
        passwordValidated = input.password.map({
            return depandency.service.validatePassword($0)
        })
        
        repeatedPasswordValidated = Driver.combineLatest(input.password, input.repeatedPassword, resultSelector: {
            return (password: $0, repeatedPassword: $1)
        }).map({
            return depandency.service.validateRepeatedPassword($0.password, repeatPassword: $0.repeatedPassword)
        })
        
        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asDriver(onErrorJustReturn: false)
        
        signedIn = input.loginTaps.withLatestFrom(Driver.combineLatest(input.username, input.password, resultSelector: { (username: $0, password: $1) } )).flatMapLatest({
            return depandency.API.signup($0.username, password: $0.password).trackActivity(signingIn).asDriver(onErrorJustReturn: false)
        }).flatMapLatest({ (loggedIn) in
            let message = loggedIn ? "登录GitHub" : "GitHub登录失败"
            return DefaultWireFrame().promptFor("提示", message: message, cancelAction: "确定", actions: []).map({ (_) in loggedIn }).asDriver(onErrorJustReturn: false)
        })
        
        signupEnabled = Driver.combineLatest(usernameValidated, passwordValidated, repeatedPasswordValidated, signingIn, resultSelector: { (un, pw, repw, sign) in
            return un.isValidate && pw.isValidate && repw.isValidate && !sign
        })
    }
}
