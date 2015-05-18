//
//  BottomMenu.swift
//  Habit Log
//
//  Created by Kohei Arai on 5/17/15.
//  Copyright (c) 2015 Kohei Arai. All rights reserved.
//

import UIKit

protocol BottomMenuProtocol {
    func bottomMenuButtonPushed()
}

class BottomMenu: UIView {
    
    let FLAT_GREEN_COLOR: UIColor = UIColor(red: 0.180, green: 0.800, blue: 0.443, alpha: 0.80)

    var bottomMenuBorder: UILabel = UILabel()
    var bottomMenuButton: UIButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
}
