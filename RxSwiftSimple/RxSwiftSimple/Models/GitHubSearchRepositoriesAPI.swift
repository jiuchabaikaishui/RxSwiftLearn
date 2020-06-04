//
//  GitHubSearchRepositoriesAPI.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/6/4.
//  Copyright © 2020 QSP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

func exampleError(_ error: String, location: String = "\(#file):\(#line)") -> NSError {
    return NSError(domain: "ExampleError", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(location): \(error)"])
}

typealias SearchRepositoriesResponse = Result<(repositories: [Repository], nextURL: URL?), GitHubServiceError>
class GitHubSearchRepositoriesAPI {
    /// 解析json
    /// - Parameters:
    ///   - response: 响应体
    ///   - data: 数据
    private static func parseJson(response: HTTPURLResponse, data: Data) throws -> AnyObject {
        // 过滤200的正确状态码
        if !(200..<300 ~= response.statusCode) {
            throw exampleError("请求失败！")
        }
        
        return try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
    }
    
    /// 加载搜索URL
    /// - Parameter searchURL: RRL
    func loadSearchURL(searchURL: URL) -> Observable<SearchRepositoriesResponse> {
        return URLSession.shared.rx.response(request: URLRequest(url: searchURL)).retry(3).observeOn(Dependencies.shareDependencies.backgroundScheduler).map { (pair) -> SearchRepositoriesResponse in
            if pair.response.statusCode == 403 {
                return .failure(.githubLimitReached)
            }
            
            let jsonRoot = try GitHubSearchRepositoriesAPI.parseJson(response: pair.response, data: pair.data)
            guard let json = jsonRoot as? [String: AnyObject] else {
                throw exampleError("数据解析错误！")
            }
            
            let repository = try Repository.parse(json)
            
            return .success((repository, URL(string: "xxxx")))
        }
    }
}

extension Repository {
    fileprivate static func parse(_ json: [String: AnyObject]) throws -> [Repository] {
        guard let items = json["items"] as? [[String: AnyObject]] else {
            throw exampleError("数据解析错误！")
        }
        
        return try items.map({ (item) in
            guard let name = item["name"] as? String, let url = item["url"] as? String else {
                throw exampleError("数据解析错误！")
            }
            
            return Repository(name: name, url: try URL(string: url).unwrap())
        })
    }
}
