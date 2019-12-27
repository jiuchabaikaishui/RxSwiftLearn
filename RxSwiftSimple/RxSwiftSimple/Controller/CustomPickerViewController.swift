//
//  CustomPickerViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2019/12/26.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit

class CustomPickerViewController: ExampleViewController {
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        button.imageView?.backgroundColor = UIColor .red
        button.titleLabel?.backgroundColor = UIColor.green
        button.backgroundColor = UIColor.blue
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
