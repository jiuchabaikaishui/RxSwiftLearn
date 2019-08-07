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

class ViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    let vm = ViewControllerVM()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            if let indexPath = tableView.indexPath(for: cell) {
                segue.destination.title = vm.rowVM(indexPath: indexPath)?.title
            }
        }
    }
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
        let cell = CommonCell(style: .subtitle, reuseIdentifier: "CommonCell")
        
        let row = vm.data[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = row.title
        cell.detailTextLabel?.text = row.detail
        if row.pushed {
            cell.accessoryType = .disclosureIndicator
        }
        
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
        if row.selected {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

