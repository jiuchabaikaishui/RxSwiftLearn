//
//  DelegateProxys.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/9/21.
//  Copyright © 2020 QSP. All rights reserved.
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        forwardToDelegate()?.locationManager?(manager, didUpdateLocations: locations)
        didUpdateLocationsSubject.onNext((manager, locations))
    }
    
    deinit {
        didUpdateLocationsSubject.onCompleted()
    }
}

class RxImagePickerDelegateProxy: RxNavigationControllerDelegateProxy, UIImagePickerControllerDelegate {
    public init(imagePicker: UIImagePickerController) {
        super.init(navigationController: imagePicker)
    }
}
