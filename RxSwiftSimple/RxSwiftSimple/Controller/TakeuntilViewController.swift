//
//  TakeuntilViewController.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/3/18.
//  Copyright © 2019年 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TakeuntilViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingUI()
        _ = Observable<Int>.interval(0.3, scheduler: SerialDispatchQueueScheduler(qos: .default)).takeUntil(self.rx.deallocated).subscribe { (event) in
                print(event)
        }
    }
    
    func settingUI() -> () {
        self.title = "Tokeuntil操作"
    }
}
