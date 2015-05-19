//
//  BlackCoverScreen.swift
//  Habit Log
//
//  Created by Kohei Arai on 5/17/15.
//  Copyright (c) 2015 Kohei Arai. All rights reserved.
//

import UIKit

protocol BlackCoverScreenProtocol {
    func blackCoverScreenTapped(sender: AnyObject)
}

class BlackCoverScreen: UIView {
    
    var isSettingOpen: Bool = false
    var isBottomOpen: Bool = false

    var delegate: BlackCoverScreenProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.blackColor()
        self.alpha = 0.0
        self.userInteractionEnabled = false
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "screenTapped:"))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func screenTapped(sender: AnyObject) {
        self.delegate?.blackCoverScreenTapped(sender)
    }
}
