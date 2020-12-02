//
//  SimpleSectionedTableViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/1/7.
//  Copyright © 2020 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SimpleSectionedTableViewController: ExampleViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let dataSource = TableViewSectionedDataSource<SectionModel<Int, Int>>(cellForRow: { (dataSource, tableView, indexPath) -> UITableViewCell in
        let cell = CommonCell.cellFor(tableView: tableView)

        let item = dataSource[indexPath]
        cell.textLabel?.text = "我是(\(indexPath.section), \(indexPath.row)), \(item)"

        return cell
    }, titleForHeader: { "第\($2)组我是\($0[$2].model)" })
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.just([
            SectionModel(model: 1, items: Array(1...10)),
            SectionModel(model: 2, items: Array(1...10)),
            SectionModel(model: 3, items: Array(1...10)),
            SectionModel(model: 4, items: Array(1...10)),
            SectionModel(model: 5, items: Array(1...10)),
            SectionModel(model: 6, items: Array(1...10)),
            SectionModel(model: 7, items: Array(1...10)),
            SectionModel(model: 8, items: Array(1...10)),
            SectionModel(model: 9, items: Array(1...10)),
            SectionModel(model: 10, items: Array(1...10))
        ]).bind(to: tableView.rx.items(dataSource: dataSource))
        .disposed(by: bag)
        
        tableView.rx.modelSelected(Int.self)
            .subscribe(onNext: { print("我是元素\($0)") })
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .flatMap { [weak self] (indexPath) -> Observable<String> in
                return DefaultWireFrame().promptFor("提示", message: "我是第\(indexPath.section)行第\(indexPath.row)个，点我干嘛？", cancelAction: "确定", actions: nil, animated: true) { self?.tableView.deselectRow(at: indexPath, animated: true) }
            }.subscribe().disposed(by: bag)
        
        tableView.rx.setDelegate(self).disposed(by: bag)
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}
