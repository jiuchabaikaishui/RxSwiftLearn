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
    private static let parseLinksPattern = "\\s*,?\\s*<([^\\>]*)>\\s*;\\s*rel=\"([^\"]*)\""
    private static let linksRegex = try! NSRegularExpression(pattern: parseLinksPattern, options: [.allowCommentsAndWhitespace])
    static let sharedAPI = GitHubSearchRepositoriesAPI()
    
    /// 解析链接
    /// - Parameter links: 链接字符串
    private static func parseLinks(links: String) throws -> [String: String] {
//        print(links)
        
        let length = (links as NSString).length
        let matches = linksRegex.matches(in: links, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: length))
        
        var result: [String: String] = [:]
        
        for m in matches {
            let matches = (1..<m.numberOfRanges).map { (index) -> String in
                let range = m.range(at: index)
                let startIndex = links.index(links.startIndex, offsetBy: range.location)
                let endIndex = links.index(links.startIndex, offsetBy: range.location + range.length)
                
                return String(links[startIndex..<endIndex])
            }
            
            if matches.count != 2 {
                throw exampleError("数据解析错误！")
            }
            
            result[matches[1]] = matches[0]
        }
        
        return result
    }
    
    /// 解析next
    /// - Parameter response: 响应体
    private static func parseNextURL(response: HTTPURLResponse) throws -> URL? {
        guard let serializedLinks = response.allHeaderFields["Link"] as? String else {
            return nil
        }
        
        let links = try parseLinks(links: serializedLinks)
        guard let nextPageURL = links["next"] else {
            return nil
        }
        
        guard let nextURL = URL(string: nextPageURL) else {
            throw exampleError("数据解析错误！")
        }
        
//        print(links)
        
        return nextURL
    }
    
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
        return URLSession.shared.rx
            .response(request: URLRequest(url: searchURL))
            .retry(3)
            .observeOn(Dependencies.shareDependencies.backgroundScheduler)
            .map { (pair) -> SearchRepositoriesResponse in
                print("----\(pair.0.url!)----")
                
                if pair.response.statusCode == 403 {
                    return .failure(.githubLimitReached)
                }
                
                let jsonRoot = try GitHubSearchRepositoriesAPI.parseJson(response: pair.response, data: pair.data)
                guard let json = jsonRoot as? [String: AnyObject] else {
                    throw exampleError("数据解析错误！")
                }
                
                let repository = try Repository.parse(json)
                let nextURL = try GitHubSearchRepositoriesAPI.parseNextURL(response: pair.response)
                
                return .success((repository, nextURL))
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
