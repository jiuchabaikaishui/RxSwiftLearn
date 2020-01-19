//
//  UserAPI.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/1/17.
//  Copyright © 2020 QSP. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class UserAPI {
    func getUsers(count: Int) -> Observable<[User]> {
        let url = URL(string: "http://api.randomuser.me/?results=\(count)")!
        return URLSession.shared.rx.json(url: url).map { (json) -> [User] in
            guard let json = json as? [String: AnyObject] else {
                fatalError()
            }
            
            guard let results = json["results"] as? [[String: AnyObject]] else {
                fatalError()
            }
            
            return results.map { (info) -> User in
                let name = info["name"] as? [String: String]
                let picture = info["picture"] as? [String: String]
                
                guard let firstName = name?["first"], let lastName = name?["last"], let imageURL = picture?["large"] else {
                    fatalError()
                }
                return User(firstName: firstName, lastName: lastName, imageURL: imageURL)
            }
        }.share(replay: 1)
    }
}
