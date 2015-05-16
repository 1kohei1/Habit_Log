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
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    let FLAT_GREEN_COLOR: UIColor = UIColor(red: 0.180, green: 0.800, blue: 0.443, alpha: 0.80)

    var settingTableView: UITableView = UITableView()
    var blackCoverScreen: UIView = UIView()
    var animationFinished = true
    var isSettingOpen = false
    
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
        self.deleteButton.hidden = true
        
        var border = CALayer()
        border.backgroundColor = UIColor.blackColor().CGColor
        border.frame = CGRectMake(0, self.borderLabel.frame.size.height, self.borderLabel.frame.size.width, 2)
        
        self.borderLabel.layer.addSublayer(border)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.menuView.commitMenuViewUpdate()
        self.calendarView.commitCalendarViewUpdate()
    }
    
    override func viewDidAppear(animated: Bool) {
        setUpSettingTableView()
}
    
    
    func setUpSettingTableView() {
        var borderLabelFrame = self.borderLabel.frame
        var yOffset = borderLabelFrame.origin.y + borderLabelFrame.size.height + 2 - 200
        
        settingTableView = UITableView(frame: CGRectMake(0, yOffset, self.view.frame.size.width, 200), style: UITableViewStyle.Grouped)
        settingTableView.delegate = self
        settingTableView.dataSource = self
        
        // UILabel to cover status bar
        var whiteLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.size.width, 28))
        whiteLabel.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(whiteLabel)
        
        // UIView for covering calendar
        blackCoverScreen.frame = self.view.frame
        blackCoverScreen.backgroundColor = UIColor.blackColor()
        blackCoverScreen.alpha = 0.0
        blackCoverScreen.userInteractionEnabled = false
        blackCoverScreen.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "settingPushed:"))
        
        self.view.bringSubviewToFront(self.habitTitle)
        self.view.bringSubviewToFront(self.borderLabel)
        self.view.bringSubviewToFront(whiteLabel)
        self.view.bringSubviewToFront(self.settingButton)
        self.view.bringSubviewToFront(self.deleteButton)
        
        self.view.insertSubview(settingTableView, belowSubview: self.habitTitle)
        self.view.insertSubview(blackCoverScreen, belowSubview: settingTableView)
    }
    
    @IBAction func settingPushed(sender: AnyObject) {
        self.blackCoverScreen.userInteractionEnabled = false
        self.deleteButton.userInteractionEnabled = false
        self.settingButton.userInteractionEnabled = false
        
        var borderLabelFrame = self.borderLabel.frame
        var yOffset: CGFloat = self.isSettingOpen ? -198.0 : -10.0

        UIView.animateWithDuration(3.0, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            
            self.settingTableView.frame.origin.y = borderLabelFrame.origin.y + borderLabelFrame.size.height + yOffset
            self.blackCoverScreen.alpha = self.isSettingOpen ? 0.0 : 0.45
            
            }, completion: {(val: Bool) -> Void in
                
                if self.isSettingOpen {
                    self.settingButton.setImage(UIImage(named: "setting2.png"), forState: UIControlState.Normal)
                    self.settingButton.tintColor = UIColor.blackColor()
                    self.deleteButton.hidden = true
                } else {
                    self.settingButton.setImage(UIImage(named: "save.png"), forState: UIControlState.Normal)
                    self.settingButton.tintColor = self.FLAT_GREEN_COLOR
                    self.deleteButton.hidden = false
                    self.blackCoverScreen.userInteractionEnabled = true
                }
                
                self.settingButton.userInteractionEnabled = true
                self.deleteButton.userInteractionEnabled = true
                self.isSettingOpen = !self.isSettingOpen
        })
    }
    
    @IBAction func deletePushed(sender: AnyObject) {

    }
    
    func blackCoverScreenPushed(sender: UITapGestureRecognizer) {
        
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Habit Title"
        } else {
            return "SECRET"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell!
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
        circle.fillColor = FLAT_GREEN_COLOR
        
        dayView.dayLabel!.textColor = UIColor.whiteColor()

        return circle
    }

}

extension ViewController {
    func printFrame(name: String, frame: CGRect) {
        println("\(name) x: \(frame.origin.x), y: \(frame.origin.y), width: \(frame.size.width), height: \(frame.size.height)")
    }
}