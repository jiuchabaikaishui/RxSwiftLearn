//
//  Randomizer.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/4/19.
//  Copyright © 2020 QSP. All rights reserved.
//

import Foundation

typealias NumberSection = SectionModel<Int, Int>


/// 混乱器
class Randomizer {
    var sections: [NumberSection]
    var unusedItems: [Int]
    var unusedSections: [Int]
    
    init(sections: [NumberSection]) {
        self.sections = sections
        self.unusedSections = []
        self.unusedItems = []
    }
    
    /// 总元素个数
    func countTotalItemsInSections() -> Int {
        sections.reduce(0) { $0 + $1.items.count }
    }
    
    /// 混乱
    func randomize() {
        var nextUnusedSections = [Int]()
        var nextUnusedItems = [Int]()
        let sectionCount = sections.count
        let itemCount = countTotalItemsInSections()
        
        /// 插入空组到随机位置
        for section in unusedSections {
            let index = Int(arc4random())%(sections.count + 1)
            sections.insert(NumberSection(model: section, items: []), at: index)
        }
        
        /// 插入项到随机位置
        for item in unusedItems {
            let sectionIndex = Int(arc4random())%sections.count
            let section = sections[sectionIndex]
            let itemCount = section.items.count
            
            if arc4random()%2 == 0 {
                let itemIndex = Int(arc4random())%(itemCount + 1)
                sections[sectionIndex].items.insert(item, at: itemIndex)
            } else {
                if itemCount == 0 {
                    sections[sectionIndex].items.insert(item, at: 0)
                } else {
                    let itemIndex = Int(arc4random())%itemCount
                    nextUnusedItems.append(sections[sectionIndex].items.remove(at: itemIndex))
                    sections[sectionIndex].items.insert(item, at: itemIndex)
                }
            }
        }
        
        let sectionActionCount = sectionCount / 3
        let itemActionCount = itemCount / 7
        
        // 随机移动部分item
        for _ in 0 ..< itemActionCount {
            if sections.count != 0 {
                let sourceSectionIndex = Int(arc4random()) % self.sections.count
                let destinationSectionIndex = Int(arc4random()) % self.sections.count
                let sectionItemCount = sections[sourceSectionIndex].items.count
                
                if sectionItemCount != 0 {
                    let sourceItemIndex = Int(arc4random()) % sectionItemCount
                    let nextRandom = Int(arc4random())
                    
                    let item = sections[sourceSectionIndex].items.remove(at: sourceItemIndex)
                    let targetItemIndex = nextRandom % (self.sections[destinationSectionIndex].items.count + 1)
                    sections[destinationSectionIndex].items.insert(item, at: targetItemIndex)
                }
            }
        }
        
        // 随机移除部分item
        for _ in 0 ..< itemActionCount {
            if self.sections.count != 0 {
                let sourceSectionIndex = Int(arc4random()) % self.sections.count
                let sectionItemCount = sections[sourceSectionIndex].items.count
                
                if sectionItemCount != 0 {
                    let sourceItemIndex = Int(arc4random()) % sectionItemCount
                    
                    nextUnusedItems.append(sections[sourceSectionIndex].items.remove(at: sourceItemIndex))
                }
            }
        }
        
        // 随机移动部分section
        for _ in 0 ..< sectionActionCount {
            if sections.count != 0 {
                let sectionIndex = Int(arc4random()) % sections.count
                let targetIndex = Int(arc4random()) % sections.count

                let section = sections.remove(at: sectionIndex)
                sections.insert(section, at: targetIndex)
            }
        }
        
        // 随机移除部分section
        for _ in 0 ..< sectionActionCount {
            if sections.count != 0 {
                let sectionIndex = Int(arc4random()) % sections.count
                let section = sections.remove(at: sectionIndex)
                
                for item in section.items {
                    nextUnusedItems.append(item)
                }

                nextUnusedSections.append(section.model)
            }
        }
        
        unusedSections = nextUnusedSections
        unusedItems = nextUnusedItems
    }
}
