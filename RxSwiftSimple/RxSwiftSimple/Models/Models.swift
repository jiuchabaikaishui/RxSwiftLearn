//
//  Models.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/8/7.
//  Copyright © 2019 QSP. All rights reserved.
//

import Foundation

enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

extension ValidationResult {
    var isValidate: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

enum SignupState {
    case signedUp(signedUp: Bool)
}


enum RetryResult {
    case retry
    case cancel
}
