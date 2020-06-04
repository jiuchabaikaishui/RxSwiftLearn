//
//  GitHubSearchRepositoriesViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/4/28.
//  Copyright © 2020 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GitHubSearchRepositoriesViewController: ExampleViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let dataSource = TableViewSectionedDataSource<SectionModel<String, Repository>>(cellForRow: { (ds, tv, ip) -> UITableViewCell in
        let cell = CommonCell.cellFor(tableView: tv)
        let repository = ds[ip]
        cell.textLabel?.text = repository.name
        cell.detailTextLabel?.text = repository.url.absoluteString
        
        return cell
    }, titleForHeader: { (ds, tv, i) -> String? in
        let section = ds[i]
        
        return section.items.count > 0 ? "\(section.items.count)个仓库" : "没有发现仓库"
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadNextPageTrigger: (Driver<GitHubSearchRepositoriesState>) -> Signal<()> = { [weak self] state in
            self!.tableView.rx.contentOffset.asDriver().withLatestFrom(state).flatMap { (state: GitHubSearchRepositoriesState) in
                // 滚动到tableView底部但不能加载下一页
                self!.tableView.isNearBottomEdge(edgeOffset: 20.0) && !state.shouldLoadNextPage ? Signal.just(()) : Signal.empty()
            }
        }
        let activityIndicator = ActivityIndicator()
        
        
    }
}
