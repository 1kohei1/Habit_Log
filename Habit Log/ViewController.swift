//
//  ViewController.swift
//  Habit Log
//
//  Created by Kohei Arai on 5/12/15.
//  Copyright (c) 2015 Kohei Arai. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var habitTitle: UILabel!
    @IBOutlet weak var borderLabel: UILabel!
    
    let BORDER_COLOR: UIColor = UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1)
    
    var animationFinished = true
    var logDates = NSArray(array: [
        CVDate(day: 3, month: 4, week: 2, year: 2015),
        CVDate(day: 9, month: 4, week: 2, year: 2015),
        CVDate(day: 19, month: 4, week: 4, year: 2015),
        CVDate(day: 22, month: 4, week: 4, year: 2015),
        CVDate(day: 3, month: 5, week: 2, year: 2015),
        CVDate(day: 6, month: 5, week: 2, year: 2015),
        CVDate(day: 8, month: 5, week: 2, year: 2015),
        CVDate(day: 10, month: 5, week: 3, year: 2015),
        CVDate(day: 12, month: 5, week: 3, year: 2015),
        CVDate(day: 14, month: 5, week: 3, year: 2015),
        ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.monthLabel.text = CVDate(date: NSDate()).globalDescription
        self.borderLabel.layer.borderWidth = 1
        self.borderLabel.layer.borderColor = BORDER_COLOR.CGColor!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.menuView.commitMenuViewUpdate()
        self.calendarView.commitCalendarViewUpdate()        
    }
    
    func printFrame(name: String, frame: CGRect) {
        println("\(name) x: \(frame.origin.x), y: \(frame.origin.y), width: \(frame.size.width), height: \(frame.size.height)")
    }
}

extension ViewController: CVCalendarMenuViewDelegate {
    func firstWeekday() -> Weekday {
        return .Sunday
    }
}

extension ViewController: CVCalendarViewDelegate {
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func didSelectDayView(dayView: CVCalendarDayView) {
        let date = dayView.date
        println("\(calendarView.presentedDate.commonDescription) is selected!")
    }
    
    func presentedDateUpdated(date: CVDate) {
        if monthLabel.text != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
            updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.animationFinished = false
                self.monthLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
                self.monthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransformIdentity
                
                }) { _ in
                    
                    self.animationFinished = true
                    self.monthLabel.frame = updatedMonthLabel.frame
                    self.monthLabel.text = updatedMonthLabel.text
                    self.monthLabel.transform = CGAffineTransformIdentity
                    self.monthLabel.alpha = 1
                    updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
    }
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if logDates.indexOfObject(dayView.date) == NSNotFound {
            return false
        } else {
            return true
        }
    }

    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        // Show logged circle
        var circle = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        circle.tag = 10
        // adjust color later
        circle.fillColor = UIColor(red: 0.180, green: 0.800, blue: 0.443, alpha: 0.80)
        
        dayView.dayLabel!.textColor = UIColor.whiteColor()

        return circle
    }

}
