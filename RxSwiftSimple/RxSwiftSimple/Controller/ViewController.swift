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
    var pushed = false
    var selectedAction: SelectedAction? = nil
}
struct TableViewSectionVM {
    var title = ""
    var rows = [TableViewRowVM]()
}
struct ViewControllerVM {
    let data = [
        TableViewSectionVM(title: "简介", rows: [
            TableViewRowVM(title: "用法", detail: "从GitHub仓库的搜索", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToUsage", sender: tableView.cellForRow(at: indexPath))
            })
        ]),
        TableViewSectionVM(title: "为何", rows: [
            TableViewRowVM(title: "绑定", detail: "从GitHub仓库的搜索", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToBanding", sender: tableView.cellForRow(at: indexPath))
            })
        ]),
        TableViewSectionVM(title: "基础", rows: [
            TableViewRowVM(title: "Disposing", detail: "观察的序列终止的一种方法。想要释放分配用于计算即将到来的元素的所有资源时，可以调用subscribe操作返回的Disposable的dispose操作。", selected: true, pushed: false, selectedAction: { controller, tableView, indexPath in
                let scheduler = SerialDispatchQueueScheduler(qos: .default)
                let subscription = Observable<Int>.interval(.milliseconds(300), scheduler: scheduler).subscribe { (event) in
                    print(event)
                }

                Thread.sleep(forTimeInterval: 2)
                
                print("dispose")
                subscription.dispose()
            }),
            TableViewRowVM(title: "Dispose Bags", detail: "Dispose Bags用于返回类似ARC行为的RX。当DisposeBag被销毁时，它将调用每个添加的disposables的dispose。", selected: true, pushed: true, selectedAction: { controller, tableView, indexPath in
                controller.performSegue(withIdentifier: "MainToDisposeBag", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "Take until", detail: "使用takeUntil操作在dealloc中自动清理订阅", selected: true, pushed: true, selectedAction: { controller, tableView, indexPath in
                let dis = TakeuntilViewController()
                if let title = (controller as? ViewController)?.vm.rowVM(indexPath: indexPath)?.title {
                    dis.title = title
                }
                
                controller.navigationController?.pushViewController(dis, animated: true)
            }),
            TableViewRowVM(title: "隐含的Observable保证", detail: "一个事件未完成时不能发送第二个事件", selected: true, pushed: true, selectedAction: { (controller, tableView, indexPath) in
                controller.performSegue(withIdentifier: "MainToImplicit", sender: tableView.cellForRow(at: indexPath))
            }),
            TableViewRowVM(title: "just", detail: "RxSwift提供了一个just方法，该方法创建一个在订阅时返回一个元素的序列", selected: true, pushed: false, selectedAction: { (controller, tableView, indexPath) in
                func myJust<E>(_ element: E) -> Observable<E> {
                    return Observable<E>.create({ (observer) -> Disposable in
                        observer.onNext(element)
                        observer.onCompleted()
                        
                        return Disposables.create()
                    })
                }
                
                let _ = myJust(0).subscribe({ (n) in
                    print(n)
                })
            }),
            TableViewRowVM(title: "create", detail: "Swift使用create闭包轻松实现subscribe方法。它接受一个参数observer，并返回disposable。", selected: true, pushed: false, selectedAction: { (controller, tableView, indexPath) in
                func myFrom<E>(_ sequese: [E]) -> Observable<E> {
                    return Observable.create({ (observer) -> Disposable in
                        for element in sequese {
                            observer.onNext(element)
                        }
                        observer.onCompleted()
                        
                        return Disposables.create()
                    })
                }
                
                let stringCounter = myFrom(["first", "second"])
                print("Started ----")
                
                let _ = stringCounter.subscribe({ (n) in
                    print(n)
                })
                print("----")
                
                let _ = stringCounter.subscribe({ (n) in
                    print(n)
                })
                print("Ended ----")
            })
        ])
    ]
    
    func rowVM(indexPath: IndexPath) -> TableViewRowVM? {
        if indexPath.section < data.count {
            let section = data[indexPath.section]
            if indexPath.row < section.rows.count {
                return section.rows[indexPath.row]
            }
        }
        
        return nil
    }
}

class CommonCell: UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        defaultSeting()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        defaultSeting()
    }
    
    func defaultSeting() {
        textLabel?.numberOfLines = 0
        detailTextLabel?.numberOfLines = 0
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
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

