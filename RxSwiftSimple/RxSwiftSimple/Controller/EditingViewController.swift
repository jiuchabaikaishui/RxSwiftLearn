//
//  EditingViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/1/13.
//  Copyright © 2020 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditingViewController: ExampleViewController {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var dataSource: TableViewSectionedDataSource<SectionModel<String, User>> = { TableViewSectionedDataSource<SectionModel<String, User>>(cellForRow: { ds, tv, indexPath in
        let cell = CommonCell.cellFor(tableView: tv)
        cell.textLabel?.text = ds[indexPath].firstName + " " + ds[indexPath].lastName
        
        return cell
    }, titleForHeader: { $0[$2].model }, canEditRow: { _,_,_ in true }, canMoveRow: { _,_,_ in true }) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem?.title = "编辑"
        
        tableView.rx.modelSelected(User.self).subscribe(onNext: { [weak self] (user) in
            let viewController = UIStoryboard(name: "EditingTableView", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            viewController.user = user
            self?.navigationController?.pushViewController(viewController, animated: true)
        }).disposed(by: bag)
        
        let events: [Observable<EditingTableViewCommand>] = [
            UserAPI().getUsers(count: 30).map { EditingTableViewCommand.addUsers(users: $0, to: IndexPath(row: 0, section: 1)) },
            tableView.rx.itemDeleted.map({ (indexPath) -> EditingTableViewCommand in
                return .deleteUser(indexPath: indexPath)
            }),
            tableView.rx.itemMoved.map(EditingTableViewCommand.moveUser)
        ]
        
        let viewModel: EditingTabelViewViewModel = EditingTabelViewViewModel()
        let scheduler = MainScheduler.instance
        
        Observable.deferred { Observable.merge(events).scan(viewModel) { $0.excuteCommand(command: $1) } }.subscribeOn(scheduler).startWith(viewModel).map({ $0.sections }).bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: bag)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.isEditing = editing
        navigationItem.rightBarButtonItem?.title = editing ? "完成" : "编辑"
    }
}
