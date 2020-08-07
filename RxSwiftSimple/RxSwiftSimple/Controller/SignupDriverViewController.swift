//
//  SignupDriverViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/25.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SignupDriverViewController: ExampleViewController {
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
        
        let vm = SignupDriverVM(input: (username: usernameOutlet.rx.text.orEmpty.asDriver(), password: passwordOutlet.rx.text.orEmpty.asDriver(), repeatedPassword: repeatOutlet.rx.text.orEmpty.asDriver(), loginTaps: signupOutlet.rx.tap.asSignal()), depandency: (API: GitHubDefaultAPI.shareApi, service: GitHubDefaultValidationService(GitHubDefaultAPI.shareApi)))
        
        // 绑定UI
        vm.usernameValidated.drive(usernameValidationOutlet.rx.validationResult)
            .disposed(by: bag)
        vm.passwordValidated.drive(passwordValidationOutlet.rx.validationResult)
            .disposed(by: bag)
        vm.repeatedPasswordValidated.drive(repeatValidationOutlet.rx.validationResult)
            .disposed(by: bag)
        
        vm.signupEnabled
            .drive(signupOutlet.rx.isEnabled)
            .disposed(by: bag)
        vm.signupEnabled
            .map { $0 ? 1.0 : 0.5 }
            .drive(signupOutlet.rx.alpha)
            .disposed(by: bag)
        vm.signingIn
            .drive(signingupOutlet.rx.isAnimating)
            .disposed(by: bag)
        vm.signingIn
            .drive(onNext: { [weak self] (signing) in
                if (signing) { self?.view.endEditing(signing) }
            }).disposed(by: bag)
        vm.signedIn
            .drive(onNext: {
                print("用户注册\($0 ? "成功" : "失败")")
            }).disposed(by: bag)
            
        let tap = UITapGestureRecognizer()
        tap.rx.event
            .subscribe(onNext: { [weak self] (tap) in
                self?.view.endEditing(true)
            }).disposed(by: bag)
        view.addGestureRecognizer(tap)
    }
}
