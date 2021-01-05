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

/// 条目数据模型
struct TableViewItemModel {
    var title: String // 标题
    var detail: String // 详情
    var canPushed = false // 能否push到下个页面
    var nextSegueID = "" // 下个页面ID
    var selectedAction: SelectedAction? = nil // 选中操作
}

/// 有效结果
enum ValidationResult {
    case ok(message: String)// 有效
    case empty // 空
    case validating // 验证中
    case failed(message: String) // 失败
}

/// 有效的颜色
struct ValidationColors {
    static let defaultColor = UIColor.black // 默认黑色
    static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0) // 有效为绿色
    static let errorColor = UIColor.red // 失败为红色
}

/// 活动令牌
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

/// 活动指示器
class ActivityIndicator: SharedSequenceConvertibleType {
    typealias Element = Bool
    typealias SharingStrategy = DriverSharingStrategy
    
    /// 锁
    let lock = NSRecursiveLock()
    /// 计数序列
    let relay = BehaviorRelay(value: 0)
    /// 加载序列
    let loading: SharedSequence<SharingStrategy, Bool>
    
    init() {
        loading = relay.asDriver().map({ $0 > 0 }).distinctUntilChanged()
    }
    deinit {
        print("\(self)销毁了")
    }
    
    /// 增量计数
    func increment() {
        lock.lock()
        relay.accept(relay.value + 1)
        lock.unlock()
    }
    /// 减量计数
    func decrement() {
        lock.lock()
        relay.accept(relay.value - 1)
        lock.unlock()
    }
    
    /// 跟踪活动
    /// - Parameter source: 源序列
    func trackActivityOfObservable<Source: ObservableConvertibleType>(_ source: Source) -> Observable<Source.Element> {
        return Observable.using({ [weak self] () -> ActivityToken<Source.Element> in
            // 增量计数
            self?.increment()
            // 返回一个Disposable
            return ActivityToken(source: source.asObservable(), disposeAction: self?.decrement ?? {})
        }, observableFactory: { (t) in
            // 返回一个序列
            t.asObservable()
        })
    }
    
    /// 遵守协议
    func asSharedSequence() -> SharedSequence<DriverSharingStrategy, Bool> {
        return loading
    }
}


/// 基本运算符
enum Operator {
    case addition // 加
    case subtruction // 减
    case multiplication // 乘
    case division // 除
}

extension Operator {
    /// 符号字符串
    var sign: String {
        switch self {
        case .addition:
            return "+"
        case .subtruction:
            return "-"
        case .multiplication:
            return "x"
        case .division:
            return "/"
        }
    }
    
    /// 执行运算
    var perform: (Double, Double) -> Double {
        switch self {
        case .addition:
            return (+)
        case .subtruction:
            return (-)
        case .multiplication:
            return (*)
        case .division:
            return (/)
        }
    }
}

/// 计算器命令
enum CalculatorCommand {
    case clear // 输入清除号
    case changeSign // 输入变换符号
    case percent // 输入百分号
    case operation(Operator) // 输入基本运算符
    case equal // 输入等号
    case addNumber(Character) // 输入数字
    case addDoc // 输入小数点
}


/// 计算器状态
enum CalculatorState {
    case oneOperand(screen: String) // 一个操作数
    case oneOperandAndOperator(operand: Double, operator: Operator) // 一个操作数和一个操作符
    case twoOperandAndOperator(operand: Double, operator: Operator, screen: String) // 两个个操作数和一个操作符
}


extension CalculatorState {
    /// 初始屏幕显示文本
    static let initalScreen = ""
    /// 初始状态
    static let inital = CalculatorState.oneOperand(screen: CalculatorState.initalScreen)
    
    /// 转换屏幕上的数据
    /// - Parameter transform: 转换闭包
    func mapScreen(transform: (String) -> String) -> CalculatorState {
        switch self {
        case let .oneOperand(screen: screen):
            return .oneOperand(screen: transform(screen))
        case let .oneOperandAndOperator(operand: operand, operator: operat):
            return .twoOperandAndOperator(operand: operand, operator: operat, screen: transform(CalculatorState.initalScreen))
        case let .twoOperandAndOperator(operand: operand, operator: operat, screen: screen):
            return .twoOperandAndOperator(operand: operand, operator: operat, screen: transform(screen))
        }
    }
    
    /// 屏幕显示数据
    var screen: String {
        switch self {
        case let .oneOperand(screen: screen):
            return screen
        case .oneOperandAndOperator(operand: _, operator: _):
            return CalculatorState.initalScreen
        case let .twoOperandAndOperator(operand: _, operator: _, screen: screen):
            return screen
        }
    }
    
    /// 屏幕显示操作符
    var sign: String {
        switch self {
        case .oneOperand(screen: _):
            return ""
        case let .oneOperandAndOperator(operand: _, operator: o):
            return o.sign
        case let .twoOperandAndOperator(operand: _, operator: o, screen: _):
            return o.sign
        }
    }
    
    func reduce(command: CalculatorCommand) -> CalculatorState {
        switch command {
        case .clear:
            return CalculatorState.inital
        case .changeSign:
            return self.mapScreen { (screen) -> String in
                if screen.count == 0 {
                    return "-"
                } else if screen[screen.startIndex] == "-" {
                    let result = screen[screen.index(after: screen.startIndex)..<screen.endIndex]
                    return String(result)
                } else {
                    return "-" + screen
                }
            }
        case .percent:
            return self.mapScreen { return "\((Double($0) ?? 0.0)/100.0)" }
        case .operation(let o):
            switch self {
            case let .oneOperand(screen: screen):
                return .oneOperandAndOperator(operand: Double(screen) ?? 0.0, operator: o)
            case let .oneOperandAndOperator(operand: operand, operator: _):
                return .oneOperandAndOperator(operand: operand, operator: o)
            case let .twoOperandAndOperator(operand: operand, operator: oo, screen: screen):
                return .twoOperandAndOperator(operand: oo.perform(operand, Double(screen) ?? 0.0), operator: o, screen: CalculatorState.initalScreen)
            }
        case .equal:
            switch self {
            case .oneOperand(screen: _):
                return self
            case let .oneOperandAndOperator(operand: operand, operator: _):
                return .oneOperand(screen: "\(operand)".removedMantisse)
            case let .twoOperandAndOperator(operand: operand, operator: oo, screen: screen):
                return .oneOperand(screen: "\(oo.perform(operand, Double(screen) ?? 0.0))".removedMantisse)
            }
        case let .addNumber(c):
            return self.mapScreen { (screen) -> String in
                if screen == CalculatorState.initalScreen {
                    return String(c)
                } else if screen == "-0" {
                    return "-" + String(c)
                } else {
                    return screen + String(c)
                }
            }
        case .addDoc:
            return self.mapScreen(transform: { $0.contains(".") || $0 == CalculatorState.initalScreen ? $0 : $0 + "." })
        }
    }
}

func debugFatalError(_ message: String) {
    #if DEBUG
        fatalError(message)
    #else
        print(message)
    #endif
}
enum DifferentiatorError : Error {
    case unwrappingOptional //解包可选类型
    case preconditionFailed(message: String)
}
