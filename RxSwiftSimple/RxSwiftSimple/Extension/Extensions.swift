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
}
