//
//  DisposeBagViewController.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/3/18.
//  Copyright © 2019年 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DisposeBagViewController: UIViewController {
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settingUI()
        
        Observable<Int>.interval(0.3, scheduler: SerialDispatchQueueScheduler(qos: .default)).subscribe { (event) in
            print(event)
        }.disposed(by: DisposeBag())//立即清理
        Observable<Int>.interval(0.3, scheduler: SerialDispatchQueueScheduler(qos: .default)).subscribe { (event) in
            print(event)
            }.disposed(by: self.disposeBag)//延迟清理
    }
    
    func settingUI() -> () {
        self.title = "Tokeuntil操作"
    }
}
