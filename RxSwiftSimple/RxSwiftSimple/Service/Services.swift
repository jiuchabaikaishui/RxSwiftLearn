//
//  Services.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/7/30.
//  Copyright © 2019 QSP. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import CoreLocation


class GeoLocationService {
    static let instance = GeoLocationService()
    private (set) var authorized: Driver<Bool>
    private (set) var location: Driver<CLLocationCoordinate2D>

    private let manager = CLLocationManager()

    init() {
        manager.distanceFilter = kCLDistanceFilterNone
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        authorized = Observable.deferred({ [unowned manager] () -> Observable<(CLLocationManager, CLAuthorizationStatus)> in
            let status = CLLocationManager.authorizationStatus()
            
            return manager.rx.didChangeAuthorization.startWith((manager, status))
        }).asDriver(onErrorJustReturn: (manager, CLAuthorizationStatus.notDetermined)).map({
            switch $0.1 {
            case .authorizedAlways:
                return true
            case .authorizedWhenInUse:
                return true
            default:
                return false
            }
        })
        
        location = manager.rx.didUpdateLocations.asDriver(onErrorJustReturn: (manager, [CLLocation]())).flatMap({
            return $0.1.last.map(Driver.just) ?? Driver.empty()
        }).map {
            $0.coordinate
        }
        
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
}
