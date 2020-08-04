//
//  Protocols.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/8/7.
//  Copyright © 2019 QSP. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


/// Github网络服务接口
protocol GithubApi {
    /// 用户名是否有效
    /// - Parameter username: 用户名
    func usernameAvailable(_ username: String) -> Observable<Bool>
    
    /// 注册
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    func signup(_ username: String, password: String) -> Observable<Bool>
}


/// GitHub数据是否有效接口
protocol GitHubValidationService {
    /// 判断用户名是否有效
    /// - Parameter username: 用户名
    func validateUsername(_ username: String) -> Observable<ValidationResult>
    
    /// 判断密码是否有效
    /// - Parameter password: 密码
    func validatePassword(_ password: String) -> ValidationResult
    
    /// 判断二次输入的密码是否有效
    /// - Parameters:
    ///   - password: 第一次输入的密码
    ///   - repeatPassword: 第二次输入的密码
    func validateRepeatedPassword(_ password: String, repeatPassword: String) -> ValidationResult
}


protocol WireFrame {
    /// 打开url
    /// - Parameter url: url
    func open(_ url: URL)
    
    /// 弹框
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 信息
    ///   - cancelAction: 取消按钮
    ///   - actions: 其他按钮数组
    ///   - animated: 是否带动画
    ///   - completion: 完成闭包
    func promptFor<Action: CustomStringConvertible>(_ title: String, message: String, cancelAction: Action, actions: [Action]?, animated: Bool, completion: (() -> Void)?) -> Observable<Action>
}
