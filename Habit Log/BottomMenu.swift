//
//  BottomMenu.swift
//  Habit Log
//
//  Created by Kohei Arai on 5/19/15.
//  Copyright (c) 2015 Kohei Arai. All rights reserved.
//

import UIKit
import QuartzCore

protocol BottomMenuProtocol {
    func buttonPushed()
}

class BottomMenu: UIView {

    let FLAT_GREEN_COLOR: UIColor = UIColor(red: 0.180, green: 0.800, blue: 0.443, alpha: 0.80)
    let FLAT_SILVER_COLOR: UIColor = UIColor(red: 0.741176, green: 0.7647, blue: 0.780392, alpha: 0.8)
    let SHOW_Y_POSITION: CGFloat
    let HIDE_Y_POSITION: CGFloat
    
    var button: UIButton?
    var delegate: BottomMenuProtocol?
    
    override init(frame: CGRect) {
        
        SHOW_Y_POSITION = frame.origin.y - 100
        HIDE_Y_POSITION = frame.origin.y
        
        super.init(frame: frame)
        
        button = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        button?.backgroundColor = FLAT_GREEN_COLOR
        button?.layer.cornerRadius = 3
        button?.tintColor = UIColor.whiteColor()
        button?.setImage(UIImage(named: "save.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        button?.frame = CGRectMake(20, 20, frame.size.width - 40, 60)
        button?.addTarget(self, action: "buttonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(button!)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateButton(isMarked: Bool) {
        if isMarked {
            button?.setTitle("Unark", forState: UIControlState.Normal)
        } else {
            button?.setTitle("Mark", forState: UIControlState.Normal)
        }
    }
    
    func buttonPushed(sender: AnyObject) {
        self.delegate?.buttonPushed()
        
        self.button?.transform = CGAffineTransformMakeScale(0.5, 0.5)
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.button?.transform = CGAffineTransformMakeScale(1, 1)
            self.button?.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }
    
    func showBottom() {
        println("show Buttom")
        UIView.animateWithDuration(0.45, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.frame.origin.y = self.SHOW_Y_POSITION
            }, completion: nil)
    }
    
    func hideBottom() {
        println("hide Buttom")
        UIView.animateWithDuration(0.45, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.frame.origin.y = self.HIDE_Y_POSITION
            }, completion: nil)
    }
    
    func setButtonOn() {
        self.button?.backgroundColor = self.FLAT_GREEN_COLOR
    }
    
    func setButtonOff() {
        self.button?.backgroundColor = self.FLAT_SILVER_COLOR
    }
}
