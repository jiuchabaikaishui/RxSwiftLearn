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
        let inputFeedback: (Driver<GitHubSearchRepositoriesState>) -> Signal<GitHubCommand> = { [weak self] state in
            let loadNextPage = loadNextPageTrigger(state).map { GitHubCommand.loadMoreItems }
            let searchText = self!.searchBar.rx.text.orEmpty.changed.asSignal()
                .throttle(.milliseconds(300))
                .map(GitHubCommand.changeSearch)
            
            return Signal.merge(loadNextPage, searchText)
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
        
        let initState = GitHubSearchRepositoriesState.initial
        let state = Driver<GitHubSearchRepositoriesState>.deferred {
            let replaySubject = ReplaySubject<GitHubSearchRepositoriesState>.create(bufferSize: 1)
            let scheduler = MainScheduler()
            let events: Observable<GitHubCommand> = Observable.merge([performSearchFeedback, inputFeedback].map({ feedback in
//                let s = replaySubject.asDriver(onErrorDriveWith: Driver.empty())
//                return feedback(s).asObservable()
                let sequence = ObservableSchedulerContext(source: replaySubject.asObservable(), scheduler: MainScheduler.asyncInstance)
                return feedback(sequence.source.asDriver(onErrorDriveWith: Driver<GitHubSearchRepositoriesState>.empty())).asObservable()
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
            .map { [SectionModel(model: "Repositories", items: $0.value)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
}

public struct ObservableSchedulerContext<Element>: ObservableType {
    public typealias Element = Element

    /// Source observable sequence
    public let source: Observable<Element>

    /// Scheduler on which observable sequence receives elements
    public let scheduler: ImmediateSchedulerType

    /// Initializes self with source observable sequence and scheduler
    ///
    /// - parameter source: Source observable sequence.
    /// - parameter scheduler: Scheduler on which source observable sequence receives elements.
    public init(source: Observable<Element>, scheduler: ImmediateSchedulerType) {
        self.source = source
        self.scheduler = scheduler
    }

    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        return self.source.subscribe(observer)
    }
}
