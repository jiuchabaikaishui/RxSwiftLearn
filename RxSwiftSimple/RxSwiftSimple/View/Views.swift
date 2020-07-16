//
//  Views.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/7/30.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit
import SnapKit


class CommonCell: UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        defaultSeting()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        defaultSeting()
    }
    
    static func cellFor(tableView: UITableView) -> CommonCell {
        let identifier = "CommonCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? CommonCell
        
        guard let result = cell else {
            return CommonCell(style: .subtitle, reuseIdentifier: identifier)
        }
        
        return result
    }
    
    func defaultSeting() {
        textLabel?.numberOfLines = 0
        detailTextLabel?.numberOfLines = 0
    }
}

class TextCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    
    static func cellFor(collectionView: UICollectionView, indexPath: IndexPath, identifier: String) -> TextCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        guard let c = cell as? TextCollectionViewCell else {
            fatalError()
        }
        
        return c
    }
}

class TextCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var textLabel: UILabel!
    
    static func viewFor(collectionView: UICollectionView, indexPath: IndexPath, kind: String, identifier: String) -> TextCollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
        guard let v = view as? TextCollectionReusableView else {
            fatalError()
        }
        
        return v
    }
}
