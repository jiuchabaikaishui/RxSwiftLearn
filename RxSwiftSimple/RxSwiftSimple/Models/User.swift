//
//  User.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/1/14.
//  Copyright © 2020 QSP. All rights reserved.
//

import Foundation

struct User: CustomStringConvertible {
    var firstName: String
    var lastName: String
    var imageURL: String
    
    var description: String {
        return "\(firstName) \(lastName)"
    }
}
