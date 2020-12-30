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
import NVActivityIndicatorView

class GitHubSearchRepositoriesViewController: ExampleViewController, NVActivityIndicatorViewable {
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
        
        return section.items.count > 0 ? "\(section.items.count)个仓库" : "没有发现\(section.model)仓库"
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 设置UI
        self.title = "Github搜索示例"
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let viewModel = GithubSearchViewModel(search: searchBar.rx.text, loadMore: tableView.rx.nearBottom())

        // 数据绑定
        viewModel.sections
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        // 选中数据
        tableView.rx.modelSelected(Repository.self)
            .subscribe(onNext: { (repository) in
                if UIApplication.shared.canOpenURL(repository.url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(repository.url, completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(repository.url)
                    }
                }
            }).disposed(by: bag)
        
        // 选中行
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] in self!.tableView.deselectRow(at: $0, animated: true) })
            .disposed(by: bag)
        
        // 网络请求中
        viewModel.loading.drive(onNext: { [weak self] in
                UIApplication.shared.isNetworkActivityIndicatorVisible = $0
                $0 && self!.tableView.isNearBottomEdge(edgeOffset: 20.0) ? self!.startAnimating() : self!.stopAnimating()
            }).disposed(by: bag)
        
        // 滑动tableView
        self.tableView.rx.contentOffset.distinctUntilChanged()
            .subscribe({ [weak self] _ in
                if self!.searchBar.isFirstResponder {
                    self!.searchBar.resignFirstResponder()
                }
            }).disposed(by: bag)
    }
}
