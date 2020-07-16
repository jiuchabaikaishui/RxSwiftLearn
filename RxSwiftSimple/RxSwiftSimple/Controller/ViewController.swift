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

class ViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    let vm = ViewControllerVM()
    let dataSource = TableViewSectionedDataSource<SectionModel<String, TableViewItemModel>>(cellForRow: { (ds, tv, ip) -> UITableViewCell in
        let cell = CommonCell.cellFor(tableView: tv)
        let model = ds[ip]
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = model.detail
        cell.accessoryType = model.canPushed ? .disclosureIndicator : .none
        
        return cell
    }, titleForHeader: { (ds, tv, i) -> String? in
        ds[i].model
    })
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? CommonCell {
            if let indexPath = tableView.indexPath(for: cell) {
                segue.destination.title = dataSource[indexPath].title
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置UI
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // 数据绑定
        vm.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        tableView.rx
            .itemSelected
            .subscribe(onNext: { [unowned self] (indexPath) in
                let model = self.dataSource[indexPath]
                
                // nextSegueID 不为空
                if !model.nextSegueID.isEmpty { self.performSegue(withIdentifier: model.nextSegueID, sender: self.tableView.cellForRow(at: indexPath)) }
                // selectedAction 有值
                if let action = model.selectedAction { action(self, self.tableView, indexPath) }
                
                // 取消tableView的选中状态
                self.tableView.deselectRow(at: indexPath, animated: true)
            }).disposed(by: bag)
    }
}

