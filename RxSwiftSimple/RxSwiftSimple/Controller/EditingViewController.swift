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
import NVActivityIndicatorView

class EditingViewController: ExampleViewController, NVActivityIndicatorViewable {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var dataSource: TableViewSectionedDataSource<SectionModel<String, User>> = { TableViewSectionedDataSource<SectionModel<String, User>>(cellForRow: { ds, tv, indexPath in
        let cell = CommonCell.cellFor(tableView: tv)
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        cell.textLabel?.text = ds[indexPath].firstName + " " + ds[indexPath].lastName
        
        return cell
    }, titleForHeader: { $0[$2].model }, canEditRow: { _,_,_ in true }, canMoveRow: { _,_,_ in true }) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem?.title = "编辑"
        
        let viewModel: EditingTabelViewViewModel = EditingTabelViewViewModel()
        let scheduler = MainScheduler.instance
        
        let addObservable =  UserAPI().getUsers(count: 30).map { EditingTableViewCommand.addUsers(users: $0, to: IndexPath(row: 0, section: 1)) }
        startAnimating()
        print(Thread.current)
        addObservable.observeOn(scheduler).subscribe(onNext: { [weak self] _ in
            print(Thread.current)
            self?.stopAnimating()
        }).disposed(by: bag)
        
        let events: [Observable<EditingTableViewCommand>] = [
           addObservable,
            tableView.rx.itemDeleted.map({ (indexPath) -> EditingTableViewCommand in
                return .deleteUser(indexPath: indexPath)
            }),
            tableView.rx.itemMoved.map(EditingTableViewCommand.moveUser)
        ]
        
        Observable.deferred { Observable.merge(events).scan(viewModel) { $0.excuteCommand(command: $1) } }.subscribeOn(scheduler).startWith(viewModel).map({ $0.sections }).bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: bag)
        
        tableView.rx.modelSelected(User.self).subscribe(onNext: { [weak self] (user) in
            let viewController = UIStoryboard(name: "EditingTableView", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            viewController.user = user
            self?.navigationController?.pushViewController(viewController, animated: true)
        }).disposed(by: bag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] in self!.tableView.deselectRow(at: $0, animated: true) }).disposed(by: bag)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.isEditing = editing
        navigationItem.rightBarButtonItem?.title = editing ? "完成" : "编辑"
    }
}
