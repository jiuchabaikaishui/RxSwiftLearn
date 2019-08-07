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
