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
        
        let loadNextPageTrigger: (Driver<GitHubSearchRepositoriesState>) -> Signal<()> = { [weak self] state in
            self!.tableView.rx.contentOffset.asDriver().withLatestFrom(state).flatMap { (state: GitHubSearchRepositoriesState) in
                // 滚动到tableView底部但不能加载下一页
                self!.tableView.isNearBottomEdge(edgeOffset: 20.0) && !state.shouldLoadNextPage ? Signal.just(()) : Signal.empty()
            }
        }
        let inputFeedback: (Driver<GitHubSearchRepositoriesState>) -> Signal<GitHubCommand> = { [weak self] state in
            let loadNextPage = loadNextPageTrigger(state).map { GitHubCommand.loadMoreItems }
            let searchText = self!.searchBar.rx.text.orEmpty.changed.asSignal()
                .throttle(.seconds(1))
                .map(GitHubCommand.changeSearch)

            return Signal.merge(loadNextPage, searchText)
        }

        let activityIndicator = ActivityIndicator()
//        let performSearchFeedback: (Driver<GitHubSearchRepositoriesState>) -> Signal<GitHubCommand> = { s in
//            s.flatMapLatest { (state) -> Signal<GitHubCommand> in
//                if !state.shouldLoadNextPage {
//                    return Signal.empty()
//                }
//                if state.searchText.isEmpty {
//                    return Signal.just(GitHubCommand.gitHubResponseReceived(Result.success((repositories: [], nextURL: nil))))
//                }
//
//                guard let url = state.nextURL else {
//                    return Signal.empty()
//                }
//                return GitHubSearchRepositoriesAPI.sharedAPI.loadSearchURL(searchURL: url)
//                    .trackActivity(activityIndicator)
//                    .asSignal(onErrorJustReturn: Result.failure(GitHubServiceError.networkError))
//                    .map(GitHubCommand.gitHubResponseReceived)
//            }
//        }

        let initState = GitHubSearchRepositoriesState.initial
//        let state = Driver<GitHubSearchRepositoriesState>.deferred {
//            let replaySubject = ReplaySubject<GitHubSearchRepositoriesState>.create(bufferSize: 1)
//            let scheduler = MainScheduler()
//            let events: Observable<GitHubCommand> = Observable.merge([performSearchFeedback, inputFeedback].map({ feedback in
//                let s = replaySubject.asDriver(onErrorDriveWith: Driver.empty())
//                return feedback(s).asObservable()
//            })).observeOn(CurrentThreadScheduler.instance)
//
//            return events.scan(initState, accumulator: GitHubSearchRepositoriesState.reduce)
//                .do(onNext: { (s) in
//                    print("++++\(s.searchText)++++")
//                    replaySubject.onNext(s)
//                }, onSubscribed: {
//                    replaySubject.onNext(initState)
//                }).subscribeOn(scheduler)
//                .startWith(initState)
//                .observeOn(scheduler)
//                .asDriver(onErrorDriveWith: .empty())
//        }
        
        let updateAll = searchBar.rx.text.orEmpty.changed
            .throttle(.milliseconds(300), scheduler: MainScheduler())
            .map(GitHubCommand.changeSearch(text:))
        let loadMore = tableView.rx.contentOffset
            .filter { [weak self] _ in self!.tableView.isNearBottomEdge(edgeOffset: 20.0) }
            .map { _ in GitHubCommand.loadMoreItems }
        
        Observable.merge(updateAll, loadMore)
            .scan(initState, accumulator: GitHubSearchRepositoriesState.reduce(state:command:))

        
        let state = Driver<GitHubSearchRepositoriesState>.empty()
        
        // 数据绑定
        state.map { $0.repositories }
            .distinctUntilChanged()
            .map { [SectionModel(model: "Repositories", items: $0.value)] }
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
        activityIndicator.drive(onNext: { [weak self] in
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
