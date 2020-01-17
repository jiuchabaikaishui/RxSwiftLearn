//
//  DetailViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/1/14.
//  Copyright © 2020 QSP. All rights reserved.
//

import UIKit
import RxSwift
import NVActivityIndicatorView

class DetailViewController: ExampleViewController, NVActivityIndicatorViewable {
    @IBOutlet weak var imageView: UIImageView!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = user.firstName + " " + user.lastName
        startAnimating()
        URLSession.shared.rx.data(request: URLRequest(url: URL(string: user.imageURL)!)).map({ UIImage(data: $0) }).catchErrorJustReturn(nil).observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] (image) in
            self?.imageView.image = image
            self?.stopAnimating()
        }).disposed(by: bag)
    }
}
