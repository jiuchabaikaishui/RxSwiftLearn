//
//  Views.swift
//  RxSwiftSimple
//
//  Created by 綦帅鹏 on 2019/7/30.
//  Copyright © 2019 QSP. All rights reserved.
//

import UIKit


class CommonCell: UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        defaultSeting()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        defaultSeting()
    }
    
    func defaultSeting() {
        textLabel?.numberOfLines = 0
        detailTextLabel?.numberOfLines = 0
    }
}
