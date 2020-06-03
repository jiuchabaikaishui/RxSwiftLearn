//
//  WikipediaSearchViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/4/27.
//  Copyright © 2020 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WikipediaSearchViewController: ExampleViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var emptyView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BaikeAPI.shareAPI.getSearchResult(word: "强力胶").subscribe(onNext: { (values) in
            print("\n------------\n\(values)\n------------")
            }).disposed(by: bag)
    }
}
