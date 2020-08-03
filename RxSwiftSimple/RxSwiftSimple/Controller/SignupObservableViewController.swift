//
//  SignupObservableViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/25.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SignupObservableViewController: ExampleViewController {
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    @IBOutlet weak var repeatOutlet: UITextField!
    @IBOutlet weak var repeatValidationOutlet: UILabel!
    @IBOutlet weak var signupOutlet: UIButton!
    @IBOutlet weak var signingupOutlet: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vm = SignupObservableVM(
            input: (
                username: usernameOutlet.rx.text.orEmpty.asObservable(),
                password: passwordOutlet.rx.text.orEmpty.asObservable(),
                repeatedPassword: repeatOutlet.rx.text.orEmpty.asObservable(),
                loginTaps: signupOutlet.rx.tap.asObservable()),
            dependency: (API: GitHubDefaultAPI.shareApi, service: GitHubDefaultValidationService(GitHubDefaultAPI.shareApi)))
        
        // 绑定UI
        vm.signupEnabled.bind(to: signupOutlet.rx.isEnabled).disposed(by: bag)
        vm.signupEnabled.map { $0 ? 1.0 : 0.5 }.bind(to: signupOutlet.rx.alpha).disposed(by: bag)
        
        vm.validatedUsername.bind(to: usernameValidationOutlet.rx.validationResult).disposed(by: bag)
        
        vm.validatedPassword.bind(to: passwordValidationOutlet.rx.validationResult).disposed(by: bag)
        
        vm.validatedRepeatedPassword.bind(to: repeatValidationOutlet.rx.validationResult).disposed(by: bag)
        
        vm.signingIn.bind(to: signingupOutlet.rx.isAnimating).disposed(by: bag)
        
        vm.signedIn.subscribe(onNext: { (signed) in
            print("用户登录\(signed ? "成功" : "失败")")
        }).disposed(by: bag)
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [weak self] (tap) in
            self?.view.endEditing(true)
        }).disposed(by: bag)
        view.addGestureRecognizer(tap)
    }
}
