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


struct UIViewControllerJumpService {
    let navigationController: UINavigationController?
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func pushNextController(name: String, title: String = "实例") {
        var nextController: UIViewController?
        if name == "TakeuntilViewController" {
            nextController = TakeuntilViewController()
        }
        
        guard let controller = nextController else {
            fatalError("\(name)控制器不存在或未实现该功能")
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

/// 定位服务
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


/// github接口
class GitHubDefaultAPI: GithubApi {
    let session: URLSession
    init(_ session: URLSession) {
        self.session = session
    }
    
    static let shareApi = GitHubDefaultAPI(URLSession.shared)
    
    /// 检验用户名是否有效
    /// - Parameter username: 用户名
    func usernameAvailable(_ username: String) -> Observable<Bool> {
        let url = URL(string: "https://github.com/\(username.URLEscaped)")!
        let request = URLRequest(url: url)
        
        // 直接获取github用户数据
        return session.rx.response(request: request).map({ (pair) -> Bool in
            // 如果404错误则用户名无效
            return pair.response.statusCode != 404
        }).catchErrorJustReturn(false)
    }
    
    /// 登录
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    func signup(_ username: String, password: String) -> Observable<Bool> {
        // 四分之一的几率失败
        let result = arc4random()%4 == 0 ? false : true
        // 模拟网络请求
        return Observable.just(result).delay(.milliseconds(1000 + Int(arc4random()%3000)), scheduler: MainScheduler.instance)
    }
}


/// 服务
class GitHubDefaultValidationService: GitHubValidationService {
    /// 接口
    let api: GithubApi
    
    /// 密码最少位数
    let minPasswordCount = 6
    /// 密码最大位数
    let maxPasswordCount = 24
    
    init(_ api: GithubApi) {
        self.api = api
    }
    
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
            return .failed(message: "密码不能小于\(minPasswordCount)6位")
        } else if password.count > maxPasswordCount {
            return .failed(message: "密码不能大于于\(maxPasswordCount)位")
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
