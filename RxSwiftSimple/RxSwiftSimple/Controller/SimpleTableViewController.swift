//
//  SimpleTableViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/1/7.
//  Copyright © 2020 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SimpleTableViewController: ExampleViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if true {
            Observable.just(0..<100)
                .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self), curriedArgument: { $2.textLabel?.text = "第\($0)行元素为：\($1)" })
                .disposed(by: bag)
        } else {
            Observable.just(0..<100)
                .bind(to: tableView.rx.items, curriedArgument: { (tv, row, element) -> UITableViewCell in
                    let cell = tv.dequeueReusableCell(withIdentifier: "CellIdentifier", for: IndexPath(row: row, section: 0))
                    cell.textLabel?.text = "第\(row)行元素为：\(element)"
                    return cell
                }).disposed(by: bag)
        }
        
        tableView.rx.itemSelected
            .flatMapLatest({ (indexPath) in
                DefaultWireFrame()
                    .promptFor("提示", message: "我是（\(indexPath.section), \(indexPath.row)），点我干嘛？", cancelAction: "确定")
                    .map { _ in indexPath }
            }).subscribe(onNext: { self.tableView.deselectRow(at: $0, animated: true) })
            .disposed(by: bag)
        
        tableView.rx.itemAccessoryButtonTapped
            .flatMap({
                        DefaultWireFrame().promptFor("提示", message: "我是（\($0.section), \($0.row)）的详细按钮，点我干嘛？", cancelAction: "确定")
            }).subscribe()
            .disposed(by: bag)
    }
}
