//
//  ViewController.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/3/5.
//  Copyright © 2019年 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

typealias SelectedAction = (_ controller: UIViewController, _ tableView: UITableView, _ indexPath: IndexPath) -> ()
struct TableViewRowVM {
    var title = ""
    var detail = ""
    var selected = false
    var selectedAction: SelectedAction? = nil
}
struct TableViewSectionVM {
    var title = ""
    var rows = [TableViewRowVM]()
}
struct ViewControllerVM {
    let data = [
        TableViewSectionVM(title: "简介", rows: [
            TableViewRowVM(title: "用法", detail: "从GitHub仓库的搜索", selected: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToUsage", sender: tableView.cellForRow(at: indexPath))
                tableView.deselectRow(at: indexPath, animated: true)
            })
        ]),
        TableViewSectionVM(title: "基础", rows: [
            TableViewRowVM(title: "interval操作", detail: "interval操作示例", selected: false, selectedAction: { controller, tableView, indexPath in
                let scheduler = SerialDispatchQueueScheduler(qos: .default)
                let subscription = Observable<Int>.interval(0.3, scheduler: scheduler).subscribe { (event) in
                    print(event)
                }

                Thread.sleep(forTimeInterval: 2)

                subscription.dispose()

                tableView.deselectRow(at: indexPath, animated: true)
            }),
            TableViewRowVM(title: "DisposeBag", detail: "DisposeBag使用示例", selected: false, selectedAction: { controller, tableView, indexPath in
                controller.performSegue(withIdentifier: "MainToDisposeBag", sender: tableView.cellForRow(at: indexPath))
                tableView.deselectRow(at: indexPath, animated: true)
            }),
            TableViewRowVM(title: "takeUntil操作", detail: "takeUntil操作示例", selected: false, selectedAction: { controller, tableView, indexPath in
                controller.performSegue(withIdentifier: "MainToTakeuntil", sender: tableView.cellForRow(at: indexPath))
                tableView.deselectRow(at: indexPath, animated: true)
            })
        ])
    ]
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    let vm = ViewControllerVM()
    let searchBar = UISearchBar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vm.data.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.data[section].rows.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UITableViewCell")
        
        let row = vm.data[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = row.title
        cell.detailTextLabel?.text = row.detail
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView(reuseIdentifier: "UITableViewHeaderFooterView")
        
        let model = vm.data[section]
        view.textLabel?.text = model.title
        
        return view
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = vm.data[indexPath.section].rows[indexPath.row]
        if let action = row.selectedAction {
            action(self, tableView, indexPath)
        }
    }
}

