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
    private static var debugSubscribe: Disposable? = nil
    private static func myInterval(_ interval: DispatchTimeInterval) -> Observable<Int> {
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
    
    let sections = Observable.just(
        [
            // 第一组数据
            SectionModel(model: "简介", items: [
                TableViewItemModel(title: "使用", detail: "从GitHub仓库的搜索", canPushed: true, nextSegueID: "MainToGitHubSearch")
            ]),
            
            // 第二组数据
            SectionModel(model: "为何使用RxSwift", items: [
                TableViewItemModel(title: "绑定", detail: "简单的UI绑定", canPushed: true, nextSegueID: "MainToBanding")
            ]),
            
            // 第三组数据
            SectionModel(model: "基础", items: [
                TableViewItemModel(title: "Disposing", detail: "观察的序列终止的一种方法。想要释放分配用于计算即将到来的元素的所有资源时，可以调用subscribe操作返回的Disposable的dispose操作。", selectedAction: { controller, tableView, indexPath in
                    let scheduler = SerialDispatchQueueScheduler(qos: .default)
                    let subscription = Observable<Int>
                        .interval(.milliseconds(300), scheduler: scheduler)
                        .subscribe { (event) in
                            print(event)
                        }

                    Thread.sleep(forTimeInterval: 2)

                    print("dispose")
                    subscription.dispose()
                }),
                TableViewItemModel(title: "Dispose Bags", detail: "Dispose Bags用于返回类似ARC行为的RX。当DisposeBag被销毁时，它将调用添加的每个disposables的dispose。", canPushed: true, nextSegueID: "MainToDisposeBag"),
                TableViewItemModel(title: "Take until", detail: "使用takeUntil操作在dealloc中自动清理订阅。", canPushed: true, selectedAction: { controller, tableView, indexPath in
                    let nextController = TakeuntilViewController()
                    if let title = (controller as? ViewController)?.dataSource[indexPath].title {
                        nextController.title = title
                    }
                    
                    controller.navigationController?.pushViewController(nextController, animated: true)
                }),
                TableViewItemModel(title: "隐含的Observable保证", detail: "一个事件未完成时不能发送第二个事件。", canPushed: true, nextSegueID: "MainToImplicit"),
                TableViewItemModel(title: "just", detail: "RxSwift提供了一个just方法，该方法创建一个在订阅时返回一个元素的序列。", selectedAction: { controller, tableView, indexPath in
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
                TableViewItemModel(title: "create", detail: "create使用Swift闭包轻松实现subscribe方法。它接受一个参数observer，并返回disposable。", selectedAction: { controller, tableView, indexPath in
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
                TableViewItemModel(title: "创建Observable执行工作", detail: "创建前面使用的interval操作符，这相当于调度队列程序的实际实现。", selectedAction: { controller, tableView, indexPath in
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
                TableViewItemModel(title: "共享订阅和share操作符", detail: "希望多个观察者仅从一个订阅共享事件（元素）使用share操作符。", selectedAction: { controller, tableView, indexPath in
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
                TableViewItemModel(title: "自定义操作符", detail: "实现未优化的map操作符。", selectedAction: { controller, tableView, indexPath in
                    let subscription = myInterval(.milliseconds(100)).myMap(transform: { (e) -> String in
                        return "This is simply \(e)"
                    }).subscribe({ (n) in
                        print(n)
                    })
                    
                    Thread.sleep(forTimeInterval: 0.5)
                    subscription.dispose()
                }),
                TableViewItemModel(title: "debug", detail: "debug运算符将所有事件打印到标准输出，也可以为这些事件添加标签。", selectedAction: { controller, tableView, indexPath in
                    let subscription = myInterval(.milliseconds(100)).debug("my probe").map({ (e) in
                        return "This is simply \(e)"
                    }).subscribe({ (n) in
                        print(n)
                    })
                    
                    Thread.sleep(forTimeInterval: 0.5)
                    subscription.dispose()
                }),
                TableViewItemModel(title: "自定义deBug操作符", detail: "实现与上面自定义操作符类似。", selectedAction: { controller, tableView, indexPath in
                    let subscription = myInterval(.milliseconds(100)).myDebug("my probe").map({ (e) in
                        return "This is simply \(e)"
                    }).subscribe({ (n) in
                        print(n)
                    })
                    
                    Thread.sleep(forTimeInterval: 0.5)
                    subscription.dispose()
                }),
                TableViewItemModel(title: "调试内存泄漏", detail: "在调试模式下，Rx在全局变量Resources.total中跟踪所有的已分配资源。如果想要一些资源泄漏检测逻辑，最简单的方法是定期打印RxSwift.Resources.total。", selectedAction: { controller, tableView, indexPath in
                    if let subscribe = ViewControllerVM.debugSubscribe {
                        subscribe.dispose()
                        ViewControllerVM.debugSubscribe = nil
                    } else {
                        ViewControllerVM.debugSubscribe = Observable<Int>.interval(.seconds(2), scheduler: MainScheduler.instance).subscribe { (_) in
                            print("Resource count \(RxSwift.Resources.total)")
                        }
                    }
                }),
                TableViewItemModel(title: "KVO", detail: "RxSwift支持rx.observe和rx.observeWeakly两种KVO方式，rx.observe性能高，因为它只是一个KVO机制的简单包装，使用场景有限。", canPushed: true, selectedAction: { controller, tableView, indexPath in
                    let nextController = KVOViewController()
                    if let title = (controller as? ViewController)?.dataSource[indexPath].title {
                        nextController.title = title
                    }
                    
                    controller.navigationController?.pushViewController(nextController, animated: true)
                }),
                TableViewItemModel(title: "发送HTTP请求", detail: "构建http请求，默认情况下，URLSession不会在MainScheduler中返回结果。", canPushed: true, selectedAction: { controller, tableView, indexPath in
                    let nextController = HTTPViewController()
                    if let title = (controller as? ViewController)?.dataSource[indexPath].title {
                        nextController.title = title
                    }
                    
                    controller.navigationController?.pushViewController(nextController, animated: true)
                })
            ]),
            
            // 第四组数据
            SectionModel(model: "特征", items: [
                TableViewItemModel(title: "Single", detail: "Single是Observable的变体，它总是保证发出单个元素或错误，而不是发出一系列元素。", canPushed: true, selectedAction: { controller, tableView, indexPath in
                    let dis = SingleViewController()
                    if let title = (controller as? ViewController)?.dataSource[indexPath].title {
                        dis.title = title
                    }
                    
                    controller.navigationController?.pushViewController(dis, animated: true)
                }),
                TableViewItemModel(title: "Completable", detail: "Completable是Observable的变体，只能完成或发出错误。保证不发出任何元素。", canPushed: true, selectedAction: { controller, tableView, indexPath in
                    let dis = CompletableViewController()
                    if let title = (controller as? ViewController)?.dataSource[indexPath].title {
                        dis.title = title
                    }
                    
                    controller.navigationController?.pushViewController(dis, animated: true)
                }),
                TableViewItemModel(title: "Maybe", detail: "Maybe是Observable的变体，它位于Single和Completable之间。它既可以发出单个元素，也可以在不发出元素的情况下完成，或者发出错误。", canPushed: true, selectedAction: { controller, tableView, indexPath in
                    let dis = MaybeViewController()
                    if let title = (controller as? ViewController)?.dataSource[indexPath].title {
                        dis.title = title
                    }
                    
                    controller.navigationController?.pushViewController(dis, animated: true)
                })
            ]),
            
            // 第五组数据
            SectionModel(model: "Schedulers", items: [
                TableViewItemModel(title: "observeOn", detail: "要在不同的Schedulers上执行工作，使用observeOn(scheduler)操作符。", selectedAction: { controller, tableView, indexPath in
                    print("0----\(Thread.current)----")
                    DispatchQueue.global().async {
                        let disposable = Observable<Int>.create { (observer) -> Disposable in
                                print("1----\(Thread.current)----")
                                observer.onNext((1))
                                observer.onCompleted()
                                return Disposables.create()
                            }.observeOn(MainScheduler.instance)
                            .map { (n) -> Int in
                                print("2----\(Thread.current)----")
                                return n + 1
                            }.subscribe { (e) in
                                print("3----\(Thread.current)----")
                                print(e)
                            }
                        
                        Thread.sleep(forTimeInterval: 1.0)
                        disposable.dispose()
                    }
                }),
                TableViewItemModel(title: "subscribeOn", detail: "要在特定scheduler上启动序列生成元素（subscribe方法）并调用dispose，请使用subscribeOn(scheduler)。", selectedAction: { controller, tableView, indexPath in
                    print("0----\(Thread.current)----")
                    DispatchQueue.global().async {
                        let disposable = Observable<Int>.create { (observer) -> Disposable in
                                print("1----\(Thread.current)----")
                                observer.onNext((1))
                                observer.onCompleted()
                                return Disposables.create()
                            }.subscribeOn(MainScheduler.instance)
                            .map { (n) -> Int in
                                print("2----\(Thread.current)----")
                                return n + 1
                            }.subscribe { (e) in
                                print("3----\(Thread.current)----")
                                print(e)
                            }
                        
                        Thread.sleep(forTimeInterval: 1.0)
                        disposable.dispose()
                    }
                })
            ]),
            
            // 第六组数据
            SectionModel(model: "示例", items: [
                TableViewItemModel(title: "绑定值", detail: "在这个示例中体会命令式与响应式编程的差异。", canPushed: true, nextSegueID: "MainToValues"),
                TableViewItemModel(title: "简单UI绑定", detail: "一个简单的UI绑定示例。", canPushed: true, nextSegueID: "MainToSimpleBinding"),
                TableViewItemModel(title: "自动输入验证", detail: "此示例包含具有进度通知的复杂异步UI验证逻辑。", canPushed: true, nextSegueID: "MainToInputIValidation")
            ]),
            
            // 第六组数据
            SectionModel(model: "官方示例", items: [
                TableViewItemModel(title: "数字相加", detail: "绑定。", canPushed: true, nextSegueID: "MainToNumbers"),
                TableViewItemModel(title: "简单验证", detail: "绑定。", canPushed: true, nextSegueID: "MainToValid"),
                TableViewItemModel(title: "定位", detail: "绑定。", canPushed: true, nextSegueID: "MainToLoction"),
                TableViewItemModel(title: "GitHub注册（使用Observable）", detail: "简单的MVVM示例。", canPushed: true, nextSegueID: "MainToSignupObservable"),
                TableViewItemModel(title: "GitHub注册（使用Driver）", detail: "简单的MVVM示例。", canPushed: true, nextSegueID: "MainToSignupDriver"),
                TableViewItemModel(title: "API包装", detail: "API包装示例。", canPushed: true, nextSegueID: "MainToWrappers"),
                TableViewItemModel(title: "计算器", detail: "无状态的计算器。", canPushed: true, nextSegueID: "MainToCalculator"),
                TableViewItemModel(title: "UIImagePickerController", detail: "UIImagePickerController绑定。", canPushed: true, nextSegueID: "MainToImagePicker"),
                TableViewItemModel(title: "UIPickerView", detail: "UIPickerView绑定。", canPushed: true, nextSegueID: "MainToPickerView"),
                TableViewItemModel(title: "简单的UITableView", detail: "简单的UITableView绑定。", canPushed: true, nextSegueID: "MainToSimpleTableView"),
                TableViewItemModel(title: "分组的UITableView", detail: "分组的UITableView绑定。", canPushed: true, nextSegueID: "MainToSimpleSectionedTableView"),
                TableViewItemModel(title: "可编辑的UITableView", detail: "可编辑的UITableView绑定。", canPushed: true, nextSegueID: "MainToEditingTableView"),
                TableViewItemModel(title: "局部刷新", detail: "UITableView、UICollectionView局部刷新。", canPushed: true, nextSegueID: "MainToPartialUpdates"),
                TableViewItemModel(title: "维基百科搜索", detail: "无法访问维基百科，此示例未实现。", canPushed: true, nextSegueID: "MainToWikipediaSearch"),
                TableViewItemModel(title: "Github代码库搜索", detail: "分页加载指示器。", canPushed: true, nextSegueID: "MainToGitHubSearch")
            ])
        ]
    )
}

class SignupObservableVM {
    // 用户名有效验证的序列
    let validatedUsername: Observable<ValidationResult>
    // 密码有效验证的序列
    let validatedPassword: Observable<ValidationResult>
    // 重复密码有效验证的序列
    let validatedRepeatedPassword: Observable<ValidationResult>
    // 允许注册的序列
    let signupEnabled: Observable<Bool>
    // 注册的序列
    let signedIn: Observable<Bool>
    // 注册中的序列
    let signingIn: Observable<Bool>
    
    /// 初始化
    /// - Parameters:
    ///   - input: 输入序列元组
    ///   - dependency: 依赖的功能模型
    init(
        input: (
            username: Observable<String>,// 用户名输入序列
            password: Observable<String>,// 密码输入序列
            repeatedPassword: Observable<String>,// 二次密码输入序列
            signTaps: Observable<Void>),// 注册点击序列
        dependency: (
            API: GithubApi,
            service: GitHubValidationService))
    {
        let api = dependency.API
        let service = dependency.service
        
        validatedUsername = input.username
            .flatMapLatest({ (name) in
            return service.validateUsername(name)
                .observeOn(MainScheduler.instance)
                .catchErrorJustReturn(.failed(message: "服务器报错"))
            }).share(replay: 1)
        
        validatedPassword = input.password
            .map({ (password) in
                return service.validatePassword(password)
            }).share(replay: 1)
        
        validatedRepeatedPassword = Observable
            .combineLatest(input.password, input.repeatedPassword, resultSelector: service.validateRepeatedPassword)
            .share(replay: 1)
        
        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asObservable()
        
        let up = Observable.combineLatest(input.username, input.password) { (username: $0, password: $1) }
        
        signedIn = input.signTaps.withLatestFrom(up).flatMapLatest({ (pair) in
            return api.signup(pair.username, password: pair.password).observeOn(MainScheduler.instance).catchErrorJustReturn(false).trackActivity(signingIn)
        }).flatMapLatest({ (loggedIn) -> Observable<Bool> in
            let message = loggedIn ? "GitHub注册成功" : "GitHub注册失败"
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
