//
//  UpdatesViewModel.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/12/15.
//  Copyright © 2020 QSP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct UpdatesViewModel {
    private var generator = Randomizer(sections: [NumberSection]())
    let sections: Driver<[NumberSection]>
    
    init(update: RxCocoa.ControlEvent<()>) {
        // 构建初始数据
        var sectionsData = [NumberSection]()
        for i in 0 ..< 10 {
            sectionsData.append(NumberSection(model: i + 1, items: Array(i ..< i + 100)))
        }
        let generator = Randomizer(sections: sectionsData)
        self.generator = generator
        
        sections = update.map { () -> [NumberSection] in
            generator.randomize()
            return generator.sections
        }.asDriver(onErrorJustReturn: sectionsData)
        .startWith(sectionsData)
    }
}
