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
        
//        let r = ReplaySubject<Int>.create(bufferSize: 1)
//        let s = MainScheduler()
//        let o = r.asObserver().do(onNext: {
//            r.onNext($0)
//        }, onSubscribed: {
//            r.onNext(1)
//            }).startWith(0)
//            .observeOn(s)
//            .subscribeOn(s)
//
//        o.subscribe(onNext: {
//            print("----\($0)----")
//            }).disposed(by: bag)
        
        let initState = GitHubSearchRepositoriesState(searchText: "AFNetworking")
//        guard let searchURL = initState.nextURL else {
//            fatalError("没有加载地址！")
//        }
//        GitHubSearchRepositoriesAPI.sharedAPI
//            .loadSearchURL(searchURL: searchURL)
//            .subscribe(onNext: { (result) in
//                print("\(result)")
//            }).disposed(by: bag)
        
//        Observable.just(())
//            .subscribe(onNext: {
//                print($0)
//            }).disposed(by: bag)
//        Observable.empty()
//            .subscribe(onNext: {
//                print($0)
//            }).disposed(by: bag)
        
        let loadNextPageTrigger: (Driver<GitHubSearchRepositoriesState>) -> Signal<()> = { [weak self] state in
            self!.tableView.rx.contentOffset.asDriver().withLatestFrom(state).flatMap { (state: GitHubSearchRepositoriesState) in
                // 滚动到tableView底部但不能加载下一页
                self!.tableView.isNearBottomEdge(edgeOffset: 20.0) && !state.shouldLoadNextPage ? Signal.just(()) : Signal.empty()
            }
        }
        let activityIndicator = ActivityIndicator()
        
        let performSearchFeedback: (Driver<GitHubSearchRepositoriesState>) -> Signal<GitHubCommand> = { s in
            s.flatMapLatest { (state) -> Signal<GitHubCommand> in
                if !state.shouldLoadNextPage {
                    return Signal.empty()
                }
                if state.searchText.isEmpty {
                    return Signal.just(GitHubCommand.gitHubResponseReceived(Result.success((repositories: [], nextURL: nil))))
                }
                
                guard let url = state.nextURL else {
                    return Signal.empty()
                }
                return GitHubSearchRepositoriesAPI.sharedAPI.loadSearchURL(searchURL: url)
                    .trackActivity(activityIndicator)
                    .asSignal(onErrorJustReturn: Result.failure(GitHubServiceError.networkError))
                    .map(GitHubCommand.gitHubResponseReceived)
            }
        }
        let inputFeedback: (Driver<GitHubSearchRepositoriesState>) -> Signal<GitHubCommand> = { s in
            let loadNextPage = loadNextPageTrigger(s).map { GitHubCommand.loadMoreItems }
            let searchText = self.searchBar.rx.text.orEmpty.changed.asSignal()
                .throttle(.milliseconds(300))
                .map(GitHubCommand.changeSearch)
            
            return Signal.merge(loadNextPage, searchText)
        }
        
        let state = Driver<GitHubSearchRepositoriesState>.deferred {
            let replaySubject = ReplaySubject<GitHubSearchRepositoriesState>.create(bufferSize: 1)
            let scheduler = MainScheduler()
            let events: Observable<GitHubCommand> = Observable.merge([performSearchFeedback, inputFeedback].map({ feedback in
                let s = replaySubject.asDriver(onErrorDriveWith: Driver.empty())
                return feedback(s).asObservable()
            }))
            
            return events.scan(initState, accumulator: GitHubSearchRepositoriesState.reduce)
                .do(onNext: { (s) in
                    replaySubject.onNext(s)
                }, onSubscribed: {
                    replaySubject.onNext(initState)
                }).subscribeOn(scheduler)
                .startWith(initState)
                .observeOn(scheduler)
                .asDriver(onErrorDriveWith: .empty())
        }
        
        state
            .map { $0.repositories }
            .distinctUntilChanged()
            .map { SectionModel(model: "Repositories", items: $0.value) }
        
        // 搜索命令
//        let searchCommand = searchBar.rx.text.orEmpty.changed
//            .throttle(.milliseconds(300), scheduler: MainScheduler())
//            .map(GitHubCommand.changeSearch)
//        searchCommand.subscribe(onNext: {
//            print("----\($0)----")
//            }).disposed(by: bag)
        
        // 加载更多命令
//        let loadMoreCommand = tableView.rx.contentOffset
//            .flatMapLatest { [unowned self] _ in
//                self.tableView.isNearBottomEdge(edgeOffset: 20.0) ? Observable.just(GitHubCommand.loadMoreItems) : Observable.empty()
//            }
//        loadMoreCommand.subscribe(onNext: {
//            print("++++\($0)++++")
//            }).disposed(by: bag)
        
        // 合并命令
//        let commands = Observable.merge([searchCommand, loadMoreCommand])
//        commands.subscribe(onNext: {
//            print("****\($0)****")
//            }).disposed(by: bag)
        
//        let state = GitHubSearchRepositoriesState.initial
//        let scheduler = MainScheduler.asyncInstance
//        let states = commands
//        .scan(state, accumulator: GitHubSearchRepositoriesState.reduce(state:command:))
//        .flatMap { (s) -> Observable<GitHubSearchRepositoriesState> in
//            print("~~~~\(s)~~~~")
//            if !s.shouldLoadNextPage {
//                return Observable.empty()
//            }
//            if s.searchText.isEmpty {
//                return Observable.just(GitHubSearchRepositoriesState.initial)
//            }
//            guard let url = s.nextURL else {
//                return Observable.empty()
//            }
//            return GitHubSearchRepositoriesAPI.sharedAPI.loadSearchURL(searchURL: url).map { (r: Result<(repositories: [Repository], nextURL: URL?), GitHubServiceError>) -> GitHubSearchRepositoriesState in
//                var result = s
//                switch r {
//                case let .success((repositories, nextURL)):
//                    result.repositories = Version(result.repositories.value + repositories)
//                    result.shouldLoadNextPage = false
//                    result.nextURL = nextURL
//                    result.failure = nil
//                case let .failure(error):
//                    result.failure = error
//                }
//                return result
//            }.subscribeOn(scheduler)
//                .observeOn(scheduler)
//                .startWith(state)
//        }
        
//        states.subscribe(onNext: {
//            print("####\($0)####")
//            }).disposed(by: bag)
        
//        states
//            .map { $0.repositories }
//            .distinctUntilChanged()
//            .map { [SectionModel(model: "Repositories", items: $0.value)] }
//            .asDriver(onErrorDriveWith: Driver.empty())
//            .drive(tableView.rx.items(dataSource: dataSource))
//            .disposed(by: bag)
    }
}
