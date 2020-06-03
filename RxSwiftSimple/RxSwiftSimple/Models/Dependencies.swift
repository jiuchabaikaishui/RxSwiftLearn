//
//  Dependencies.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/4/28.
//  Copyright © 2020 QSP. All rights reserved.
//

import Foundation
import RxSwift

class Dependencies {
    static let shareDependencies = Dependencies()
    
    let urlSession = URLSession.shared
    let backgroundScheduler: ImmediateSchedulerType
    let mainScheduler: SerialDispatchQueueScheduler
    let wireframe: WireFrame
    
    init() {
        wireframe = DefaultWireFrame()
        mainScheduler = MainScheduler.instance
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = QualityOfService.userInitiated
        backgroundScheduler = OperationQueueScheduler(operationQueue: operationQueue)
    }
}
