//
//  GitHubSearchRepositoriesState.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/5/12.
//  Copyright © 2020 QSP. All rights reserved.
//

import Foundation

enum GitHubServiceError: Error {
    case offline
    case githubLimitReached
    case networkError
}
struct Repository: CustomDebugStringConvertible {
    var name: String
    var url: URL

    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
    
    var debugDescription: String {
        return "\(name) | \(url)"
    }
}
class Unique: NSObject {
}

enum GitHubCommand {
    case changeSearch(text: String)
    case loadMoreItems
    case gitHubResponseReceived(SearchRepositoriesResponse)
}

struct Version<Value>: Hashable {

    private let _unique: Unique
    let value: Value

    init(_ value: Value) {
        self._unique = Unique()
        self.value = value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self._unique)
    }

    static func == (lhs: Version<Value>, rhs: Version<Value>) -> Bool {
        return lhs._unique === rhs._unique
    }
}

struct GitHubSearchRepositoriesState {
    static let initial = GitHubSearchRepositoriesState(searchText: "")
    
    var searchText: String
    var shouldLoadNextPage: Bool
    var repositories: Version<[Repository]>
    var nextURL: URL?
    var failure: GitHubServiceError?

    init(searchText: String) {
        self.searchText = searchText
        shouldLoadNextPage = true
        repositories = Version([])
        nextURL = URL(string: "https://api.github.com/search/repositories?q=\(searchText.URLEscaped)")
        failure = nil
    }
    
    static func reduce(state: GitHubSearchRepositoriesState, command: GitHubCommand) -> Self {
        var result = state
        switch command {
        case let .changeSearch(text):
            result = GitHubSearchRepositoriesState(searchText: text)
            result.failure = state.failure
        case let .gitHubResponseReceived(response):
            switch response {
            case let .success((repositories, url)):
                result.repositories = Version(state.repositories.value + repositories)
                result.shouldLoadNextPage = false
                result.nextURL = url
                result.failure = nil
            case let .failure(error):
                result.failure = error
            }
        case .loadMoreItems:
            if state.failure == nil {
                result.shouldLoadNextPage = true
            }
        }
        return result
    }
}
