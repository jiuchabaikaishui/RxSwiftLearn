//
//  ValidViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/25.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ValidViewController: ExampleViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var usernameValid: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordValid: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let minUsernameLength = 6
        let minPasswordLength = 6
        usernameValid.text = "用户名至少\(minUsernameLength)个字符……"
        passwordValid.text = "密码至少\(minUsernameLength)个字符……"
        
        let usernameV = username.rx.text.orEmpty.map { $0.count >= minUsernameLength }.share(replay: 1)
        let passwordV = password.rx.text.orEmpty.map { $0.count >= minPasswordLength }.share(replay: 1)
        let buttonV = Observable.combineLatest(usernameV, passwordV) { $0 && $1 }.share(replay: 1)
        
        usernameV.bind(to: password.rx.isEnabled).disposed(by: bag)
        usernameV.bind(to: usernameValid.rx.isHidden).disposed(by: bag)
        passwordV.bind(to: passwordValid.rx.isHidden).disposed(by: bag)
        buttonV.bind(to: button.rx.isEnabled).disposed(by: bag)
        button.rx.tap.subscribe {[unowned self] (_) in
            let alert = UIAlertController(title: "提示", message: "登录成功！", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }.disposed(by: bag)
    }
}
