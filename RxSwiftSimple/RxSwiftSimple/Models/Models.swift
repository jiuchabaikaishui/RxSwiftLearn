//
//  Models.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/8/7.
//  Copyright © 2019 QSP. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

struct ValidationColors {
    static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
    static let errorColor = UIColor.red
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
    var description: String {
        switch self {
        case let .ok(message):
            return message
        case .empty:
            return ""
        case .validating:
            return "加载中..."
        case let .failed(message):
            return message
        }
    }
    var textColor: UIColor {
        switch self {
        case .ok:
            return ValidationColors.okColor
        case .empty:
            return UIColor.black
        case .validating:
            return UIColor.black
        case .failed:
            return ValidationColors.errorColor
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

struct ActivityToken<E>: ObservableConvertibleType, Disposable {
    let _source: Observable<E>
    let _dispose: Cancelable
    
    init(source: Observable<E>, disposeAction: @escaping () -> Void) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }
    func asObservable() -> Observable<E> {
        return _source
    }
    
    func dispose() {
        _dispose.dispose()
    }
}

class ActivityIndicator: SharedSequenceConvertibleType {
    typealias Element = Bool
    typealias SharingStrategy = DriverSharingStrategy
    
    let lock = NSRecursiveLock()
    let relay = BehaviorRelay(value: 0)
    let loading: SharedSequence<SharingStrategy, Bool>
    
    init() {
        loading = relay.asDriver().map({ $0 > 0 }).distinctUntilChanged()
    }
    
    func increment() {
        lock.lock()
        relay.accept(relay.value + 1)
        lock.unlock()
    }
    func decrement() {
        lock.lock()
        relay.accept(relay.value - 1)
        lock.unlock()
    }
    func asSharedSequence() -> SharedSequence<DriverSharingStrategy, Bool> {
        return loading
    }
    func trackActivityOfObservable<Source: ObservableConvertibleType>(_ source: Source) -> Observable<Source.Element> {
        return Observable.using({ () -> ActivityToken<Source.Element> in
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        }, observableFactory: { (t) in
            t.asObservable()
        })
    }
}
