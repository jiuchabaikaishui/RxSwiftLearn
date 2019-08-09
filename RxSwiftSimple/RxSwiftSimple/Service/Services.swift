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


class GitHubDefaultAPI: GithubApi {
    let session: URLSession
    init(_ session: URLSession) {
        self.session = session
    }
    
    static let shareApi = GitHubDefaultAPI(URLSession.shared)
    
    func usernameAvailable(_ username: String) -> Observable<Bool> {
        let url = URL(string: "https://github.com/\(username.URLEscaped)")!
        let request = URLRequest(url: url)
        
        return session.rx.response(request: request).map({ (pair) -> Bool in
            return pair.response.statusCode == 404
        }).catchErrorJustReturn(false)
    }
    
    func signup(_ username: String, password: String) -> Observable<Bool> {
        let result = arc4random()%2 == 0 ? false : true
        return Observable.just(result).delay(.seconds(1 + Int(arc4random()%3)), scheduler: MainScheduler.instance)
    }
}


class GitHubDefaultValidationService: GitHubValidationService {
    let api: GithubApi
    init(_ api: GithubApi) {
        self.api = api
    }
    
    let minPasswordCount = 6
    
    func validateUsername(_ username: String) -> Observable<ValidationResult> {
        if username.isEmpty {
            return .just(.empty)
        }
        
        let loadingValue = ValidationResult.validating
        
        return api.usernameAvailable(username).map({ (vailable) -> ValidationResult in
            if vailable {
                return .ok(message: "用户名有效")
            } else {
                return .failed(message: "用户名无效")
            }
        }).startWith(loadingValue)
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return .empty
        }
        
        if password.count < minPasswordCount {
            return .failed(message: "密码不能小于6位")
        }
        
        return .ok(message: "密码可用")
    }
    
    func validateRepeatedPassword(_ password: String, repeatPassword: String) -> ValidationResult {
        if repeatPassword.isEmpty {
            return .empty
        }
        
        if repeatPassword == password {
            return .ok(message: "密码相同")
        } else {
            return .failed(message: "密码不同")
        }
    }
}
