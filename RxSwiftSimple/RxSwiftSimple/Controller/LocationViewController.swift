//
//  LocationViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/25.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class LocationViewController: ExampleViewController {
    @IBOutlet weak var noGeolocationView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button1: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(noGeolocationView)
        noGeolocationView.snp.makeConstraints { (maker) in
            maker.left.top.right.bottom.equalTo(view)
        }
        
        let service = GeoLocationService.instance
        
        service.authorized.drive(noGeolocationView.rx.isHidden).disposed(by: bag)
        
        service.location.drive(label.rx.coordinate).disposed(by: bag)
        
        button.rx.tap.bind {[unowned self] in self.openAppPreferences() }.disposed(by: bag)
        
        button1.rx.tap.bind {[unowned self] in self.openAppPreferences() }.disposed(by: bag)
    }
    
    private func openAppPreferences() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}
