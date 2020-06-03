//
//  BaikeAPI.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/4/27.
//  Copyright © 2020 QSP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class BaikeAPI {
    static let shareAPI = BaikeAPI()
    
    let dependencies = Dependencies.shareDependencies
    let loadingData = ActivityIndicator()
    
    func getSearchResult(word: String) -> Observable<Any> {
        let url = URL(string: "https://baike.baidu.com/search?word=\(word.URLEscaped)")
        let request = URLRequest(url: url!)

        return dependencies.urlSession.rx.data(request: request).trackActivity(loadingData).observeOn(dependencies.backgroundScheduler).map { (data) in
            guard let text = String(data: data, encoding: .utf8) else {
                fatalError("数据错误")
            }
            
            return text
        }
    }
}
