//
//  ViewController.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/3/5.
//  Copyright © 2019年 QSP. All rights reserved.
//

import UIKit
import RxSwift

typealias SelectedAction = (_ tableView: UITableView, _ indexPath: IndexPath) -> ()
struct TableViewRow {
    var title = ""
    var detail = ""
    var selectedAction: SelectedAction? = nil
}
struct TableViewSection {
    var title = ""
    var detail = ""
    var rows = [TableViewRow]()
}
class ViewControllerVM: NSObject {
    
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    let data = [
                TableViewSection(title: "基础", detail: "都是基础示例", rows: [TableViewRow(title: "a", detail: "b", selectedAction: { tableView, indexPath in
                    let scheduler = SerialDispatchQueueScheduler(qos: .default)
                    let subscription = Observable<Int>.interval(0.3, scheduler: scheduler).subscribe { (event) in
                        print(event)
                    }
                    
                    Thread.sleep(forTimeInterval: 2)
                    
                    subscription.dispose()
                    
                    tableView.deselectRow(at: indexPath, animated: true)
                })])
               ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.data.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data[section].rows.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UITableViewCell")
        
        let row = self.data[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = row.title
        cell.detailTextLabel?.text = row.detail
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView(reuseIdentifier: "UITableViewHeaderFooterView")
        
        let model = self.data[section]
        view.textLabel?.text = model.title
        
        return view
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { 
    }
}

