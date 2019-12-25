//
//  ImagePickerController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/25.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ImagePickerController: BaseViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var cropButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 拍照是否可用
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        cameraButton.rx.tap.flatMapLatest { [weak self] _ in
            return UIImagePickerController.rx.createWithParent(parent: self, animated: true) { (picker) in
                picker.sourceType = .camera
                picker.allowsEditing = false
            }.flatMap { $0.rx.didFinishPickingMediaWithInfo }.take(1)
        }.map { $0[.originalImage] as? UIImage }.bind(to: imageView.rx.image).disposed(by: bag)
        
        galleryButton.rx.tap.flatMapLatest { [weak self] (_) in
            return UIImagePickerController.rx.createWithParent(parent: self) { (picker) in
                picker.sourceType = .photoLibrary
                picker.allowsEditing = false
                }.flatMap { $0.rx.didFinishPickingMediaWithInfo }.take(1)
        }.map { $0[.originalImage] as? UIImage }.bind(to: imageView.rx.image).disposed(by: bag)
        
        cropButton.rx.tap.flatMapLatest { [weak self] (_) in
            return UIImagePickerController.rx.createWithParent(parent: self) { (picker) in
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                }.flatMap { $0.rx.didFinishPickingMediaWithInfo }.take(1)
        }.map { $0[.editedImage] as? UIImage }.bind(to: imageView.rx.image).disposed(by: bag)
    }
}
