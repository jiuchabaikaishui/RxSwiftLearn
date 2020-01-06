//
//  Extensions.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/8/1.
//  Copyright © 2019 QSP. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa


extension ObservableType {
    func myMap<R>(transform: @escaping (Element) -> R) -> Observable<R> {
        return Observable.create({ (observer) -> Disposable in
            let subscription = self.subscribe({ (e) in
                switch e {
                case .next(let value):
                    let result = transform(value)
                    observer.onNext(result)
                case .error(let error):
                    observer.onError(error)
                case .completed:
                    observer.onCompleted()
                }
            })
            
            return subscription
        })
    }
    func myDebug(_ identifier: String) -> Observable<Self.Element> {
        return Observable<Element>.create({ (observer) -> Disposable in
            print("subscribed \(identifier)")
            
            let subscription = self.subscribe({ (e) in
                print("event \(identifier)  \(e)")
                switch e {
                case .next(let value):
                    observer.onNext(value)
                case .error(let error):
                    observer.onError(error)
                case .completed:
                    observer.onCompleted()
                }
            })
            
            return subscription
        })
    }
}


extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}


class CLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
    
    init(manager: CLLocationManager) {
        super.init(parentObject: manager, delegateProxy: CLLocationManagerDelegateProxy.self)
    }
    static func registerKnownImplementations() {
        self.register { CLLocationManagerDelegateProxy(manager: $0) }
    }
    
    internal lazy var didUpdateLocationsSubject = PublishSubject<(CLLocationManager, [CLLocation])>()
    internal lazy var didChangeAuthorizationSubject = PublishSubject<(CLLocationManager, CLAuthorizationStatus)>()
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocationsSubject.onNext((manager, locations))
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        didChangeAuthorizationSubject.onNext((manager, status))
    }
}


extension Reactive where Base: CLLocationManager {
    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return CLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    var didUpdateLocations: Observable<(CLLocationManager, [CLLocation])> {
        return CLLocationManagerDelegateProxy.proxy(for: base).didUpdateLocationsSubject
    }
    var didChangeAuthorization: Observable<(CLLocationManager, CLAuthorizationStatus)> {
        return CLLocationManagerDelegateProxy.proxy(for: base).didChangeAuthorizationSubject
    }
}


extension Reactive where Base: UILabel {
    var coordinate: Binder<CLLocationCoordinate2D> {
        return Binder(base, binding: { (label, location) in
            label.text = "Lat: \(location.latitude)\nLon: \(location.longitude)"
        })
    }
    var validationResult: Binder<ValidationResult> {
        return Binder(base, binding: { (label, result) in
            label.textColor = result.textColor
            label.text = result.description
        })
    }
    
}


extension ObservableConvertibleType {
    func trackActivity(_ indicator: ActivityIndicator) -> Observable<Element> {
        return indicator.trackActivityOfObservable(self)
    }
}


extension String {
    var URLEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
    var removedMantisse: String {
        if self.contains(".") && (self.last == "0" || self.last == ".") {
            return String(self[..<self.index(before: self.endIndex)]).removedMantisse
        } else {
            return self
        }
    }
}


func dismissViewController(viewController: UIViewController, animated: Bool) {
    /// 是否有控制器在进程中没有显示或消失
    if viewController.isBeingPresented || viewController.isBeingDismissed {
        DispatchQueue.main.async {// 异步递归调用
            dismissViewController(viewController: viewController, animated: animated)
        }
    } else if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}

private func castOrThrow<T>(resultType: T.Type, object: Any) throws -> T {
    guard let resultValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return resultValue
}

extension Reactive where Base: UIImagePickerController {
    public var didCancel: Observable<()> {
        return delegate.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:))).map { (_) -> () in }
    }
    public var didFinishPickingMediaWithInfo: Observable<[UIImagePickerController.InfoKey: AnyObject]> {
        return delegate.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:))).map { (a) in
            return try castOrThrow(resultType: Dictionary<UIImagePickerController.InfoKey, AnyObject>.self, object: a[1])
        }
    }
    
    /// 创建图片选择控制器Observable
    /// - Parameters:
    ///   - parent: 父控制器
    ///   - animated: 动画
    ///   - configureImagePicker: 配置闭包
    static func createWithParent(parent: UIViewController?, animated: Bool = true, configureImagePicker: @escaping (UIImagePickerController) throws -> Void) -> Observable<UIImagePickerController> {
        return Observable.create { [weak parent] (observer) -> Disposable in
            let imagePicker = UIImagePickerController()
            // 取消操作
            let dismissDisposable = imagePicker.rx.didCancel.subscribe(onNext: { [weak imagePicker] (_) in
                guard let imagePicker = imagePicker else {
                    return
                }
                
                dismissViewController(viewController: imagePicker, animated: animated)
            })
            
            // 处理配置闭包
            do {
                try configureImagePicker(imagePicker)
            } catch let error {
                observer.onError(error)
                return Disposables.create()
            }
            
            guard let parent = parent else {
                observer.onCompleted()
                return Disposables.create()
            }
            parent.present(imagePicker, animated: animated, completion: nil)
            observer.on(.next(imagePicker))
            
            return Disposables.create(dismissDisposable, Disposables.create {
                dismissViewController(viewController: imagePicker, animated: animated)
            })
        }
    }
}



extension UIColor {
    /// 随机颜色
    class var random: UIColor { UIColor(red: CGFloat(arc4random()%256)/255.0, green: CGFloat(arc4random()%256)/255.0, blue: CGFloat(arc4random()%256)/255.0, alpha: 1) }
}

extension Reactive where Base: UIPickerView {
    public var delegate: DelegateProxy<UIPickerView, UIPickerViewDelegate> {
        return RxPickerViewDelegateProxy.proxy(for: base)
    }
}
