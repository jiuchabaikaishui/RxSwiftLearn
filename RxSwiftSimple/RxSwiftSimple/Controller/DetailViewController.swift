//
//  DetailViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/1/14.
//  Copyright © 2020 QSP. All rights reserved.
//

import UIKit
import RxSwift

class DetailViewController: ExampleViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = user.firstName + " " + user.lastName
        URLSession.shared.rx.data(request: URLRequest(url: URL(string: user.imageURL)!)).map({ UIImage(data: $0) }).observeOn(MainScheduler.instance).catchErrorJustReturn(nil).subscribe(imageView.rx.image).disposed(by: bag)
    }
}
