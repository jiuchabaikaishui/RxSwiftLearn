//
//  PickerViewViewAdapter.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/1/7.
//  Copyright © 2020 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseSectionedPickerViewAdapter<T: CustomStringConvertible>: NSObject, UIPickerViewDataSource, RxPickerViewDataSourceType, SectionedViewDataSourceType {
    typealias Element = [[T]]
    fileprivate var items: Element = []
    
    func model(at indexPath: IndexPath) throws -> Any {
        items[indexPath.section][indexPath.row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        items.count
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        items[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, observedEvent: Event<[[T]]>) {
        Binder(self) { (adapter, items) in
            adapter.items = items
            pickerView.reloadAllComponents()
        }.on(observedEvent)
    }
}

class SimpleSectionedPickerViewAdapter<T: CustomStringConvertible>: BaseSectionedPickerViewAdapter<T>, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[component][row].description
    }
}

class SectionedPickerViewAdapter<T: CustomStringConvertible>: BaseSectionedPickerViewAdapter<T>, UIPickerViewDelegate {
    private var viewForRow: ((UIPickerView, Int, Int, UIView?) -> UIView)?
    private var titleForRow: ((UIPickerView, Int, Int) -> String)?
    private var attributedTitleForRow: ((UIPickerView, Int, Int) -> NSAttributedString)?
    private var widthForComponent: ((UIPickerView, Int) -> CGFloat)?
    private var heightForComponent: ((UIPickerView, Int) -> CGFloat)?
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if let aView = viewForRow {
            return aView(pickerView, row, component, view)
        } else {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 21.0)
            if let aAttributedTitle = attributedTitleForRow {
                label.attributedText = aAttributedTitle(pickerView, row, component)
            }
            else if let aTitle = titleForRow {
                label.text = aTitle(pickerView, row, component)
            }
            else {
                label.text = items[component][row].description
            }
            
            return label
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if let width = widthForComponent {
            return width(pickerView, component)
        }
        
        return floor(UIScreen.main.bounds.width/CGFloat(items.count))
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if let aHeight = heightForComponent {
            return aHeight(pickerView, component)
        }
        
        return 34.0
    }
    
    init(viewForRow: ((UIPickerView, Int, Int, UIView?) -> UIView)?, widthForComponent: ((UIPickerView, Int) -> CGFloat)? = nil, heightForComponent: ((UIPickerView, Int) -> CGFloat)? = nil, titleForRow: ((UIPickerView, Int, Int) -> String)? = nil, attributedTitleForRow: ((UIPickerView, Int, Int) -> NSAttributedString)? = nil) {
        super.init()
        self.viewForRow = viewForRow
        self.widthForComponent = widthForComponent
        self.heightForComponent = heightForComponent
    }
}

extension Reactive where Base: UIPickerView {
    func sectionedItems<T: CustomStringConvertible>
        (_ source: Observable<[[T]]>)
    -> ((viewForRow: (UIPickerView, Int, Int, UIView?) -> UIView, widthForComponent: ((UIPickerView, Int) -> CGFloat)?, heightForComponent: ((UIPickerView, Int) -> CGFloat)?, titleForRow:((UIPickerView, Int, Int) -> String)?, attributedTitleForRow: ((UIPickerView, Int, Int) -> NSAttributedString)?))
    -> Disposable {
        return { arg in
            let adapter = SectionedPickerViewAdapter<T>(viewForRow: arg.0, widthForComponent: arg.1, heightForComponent: arg.2, titleForRow: arg.3, attributedTitleForRow: arg.4)
            return items(adapter: adapter)(source)
        }
    }
}
