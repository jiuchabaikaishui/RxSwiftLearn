//
//  PartialUpdatesViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/4/6.
//  Copyright © 2020 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PartialUpdatesViewController: ExampleViewController {
    private let cellID = "TextCollectionViewCell"
    private let reusableViewID = "TextCollectionReusableView"
    
    @IBOutlet weak var partialTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var partialCollectionView: UICollectionView!
    
    lazy var tableViewDataSource = {
        TableViewSectionedDataSource<NumberSection>(cellForRow: { (ds, tv, ip) -> UITableViewCell in
            let cell = CommonCell.cellFor(tableView: tv)
            cell.textLabel?.text = "\(ds[ip])"
            return cell
        }, titleForHeader: { (ds, tv, i) -> String? in
            return "第\(ds[i].model)组"
        })
    }()
    lazy var collectionViewDataSource = {
        CollectionViewSectionedDataSource<NumberSection>(cellForItem: { [weak self] (ds, cv, ip) -> UICollectionViewCell in
            let cell = TextCollectionViewCell.cellFor(collectionView: cv, indexPath: ip, identifier: self!.cellID)
            cell.textLabel.text = "\(ds[ip])"
            return cell
        }, viewForSupplementaryElement: { [weak self] (ds, cv, kind, ip) -> UICollectionReusableView in
            let view = TextCollectionReusableView.viewFor(collectionView: cv, indexPath: ip, kind: kind, identifier: self!.reusableViewID)
            view.textLabel.text = "第\(ds[ip.section].model)组"
            return view
        })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 构建UI
        let rightItem = UIBarButtonItem(title: "更新", style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = rightItem
        
        // 绑定
        let viewModel = UpdatesViewModel(update: rightItem.rx.tap)
        viewModel.sections
            .drive(partialTableView.rx.items(dataSource: tableViewDataSource))
            .disposed(by: bag)
        viewModel.sections
            .drive(tableView.rx.items(dataSource: tableViewDataSource))
            .disposed(by: bag)
        Observable.of(tableView.rx.modelSelected(Int.self), partialTableView.rx.modelSelected(Int.self))
            .merge()
            .subscribe(onNext: {print("我是\($0)") })
            .disposed(by: bag)
        
        viewModel.sections
            .drive(partialCollectionView.rx.items(dataSource: collectionViewDataSource))
            .disposed(by: bag)
        partialCollectionView.rx
            .modelSelected(Int.self)
            .subscribe(onNext: { print("我是\($0)") })
            .disposed(by: bag)
    }
}
