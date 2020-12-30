//
//  GithubSearchViewModel.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/12/21.
//  Copyright © 2020 QSP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct GithubSearchViewModel {
    private let activity: ActivityIndicator
    let loading: Driver<Bool>
    let sections: Driver<[SectionModel<String, Repository>]>
    let bag = DisposeBag()

    init(search: RxCocoa.ControlProperty<String?>, loadMore: Observable<(Bool)>) {
        let activityIndicator = ActivityIndicator()
        activity = activityIndicator
        loading = activityIndicator.loading
        let searchText = search.orEmpty.changed
            .asDriver()
            .throttle(.seconds(1))
            .distinctUntilChanged()
            .map(GitHubCommand.changeSearch)

        let loadNextPage = loadMore
            .withLatestFrom(loading, resultSelector: { $0 && (!$1) })
            .filter({ $0 })
            .map({ _ in GitHubCommand.loadMoreItems })
            .asDriver(onErrorDriveWith: Driver.empty())
        
        let inputFeedback: (Driver<GitHubSearchRepositoriesState>) -> Driver<GitHubCommand> = { state in
            let performSearch = state.flatMapLatest { (state) -> Driver<GitHubCommand> in
                if !state.shouldLoadNextPage {
                    return Driver.empty()
                }
                if state.searchText.isEmpty {
                    return Driver.empty()
                }

                guard let url = state.nextURL else {
                    return Driver.empty()
                }
                return GitHubSearchRepositoriesAPI.sharedAPI.loadSearchURL(searchURL: url)
                    .trackActivity(activityIndicator)
                    .asDriver(onErrorJustReturn: Result.failure(GitHubServiceError.networkError))
                    .map(GitHubCommand.gitHubResponseReceived)
            }
            return Driver.merge(searchText, loadNextPage, performSearch)
        }
        
        sections = Driver<GitHubSearchRepositoriesState>.deferred {
            let subject = ReplaySubject<GitHubSearchRepositoriesState>.create(bufferSize: 1)
            let commands = inputFeedback(subject.asDriver(onErrorDriveWith: Driver.empty()))
            return commands.scan(GitHubSearchRepositoriesState.initial, accumulator: GitHubSearchRepositoriesState.reduce(state:command:))
                .do { (s) in
                    subject.onNext(s)
                } onSubscribed: {
                    subject.onNext(GitHubSearchRepositoriesState.initial)
                }.startWith(GitHubSearchRepositoriesState.initial)
        }.map { [SectionModel(model: "Repositories", items: $0.repositories.value)] }
    }
}
