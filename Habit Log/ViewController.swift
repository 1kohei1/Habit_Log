//
//  ViewController.swift
//  Habit Log
//
//  Created by Kohei Arai on 5/12/15.
//  Copyright (c) 2015 Kohei Arai. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController, CoreDataHandlerDelegate {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    @IBOutlet weak var habitTitle: UILabel!
    @IBOutlet weak var borderLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    let FLAT_GREEN_COLOR: UIColor = UIColor(red: 0.180, green: 0.800, blue: 0.443, alpha: 0.80)

    var settingTableView: SettingTableView = SettingTableView()
    var blackCoverScreen: BlackCoverScreen = BlackCoverScreen()
    var animationFinished = true
    
    var coreDataHandler: CoreDataHandler?
    var selected_habit_index: Int = -1
    var selectedDayView: CVCalendarDayView?
    
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
        
        // Not sure if this is the right place to initiate coreDataHandler
        self.coreDataHandler = CoreDataHandler(delegate: self)
        selected_habit_index = self.coreDataHandler!.getSelectedHabitIndex()
        self.habitTitle.text = self.coreDataHandler!.getSelectedHabitInfo(selected_habit_index).valueForKey("title") as? String
        
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
        reflectHabitChange()
    }
    
    func setUpSettingTableView() {
        // UILabel to cover status bar
        var whiteLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.size.width, 28))
        whiteLabel.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(whiteLabel)

        var borderLabelFrame = self.borderLabel.frame
        var yOffset = borderLabelFrame.origin.y + borderLabelFrame.size.height + 2 - 244
        
        settingTableView = SettingTableView(frame: CGRectMake(0, yOffset, self.view.frame.size.width, 244))
        settingTableView.delegate = self
        
        blackCoverScreen = BlackCoverScreen(frame: self.view.frame)
        blackCoverScreen.delegate = self
        
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
        var yOffset: CGFloat = blackCoverScreen.isSettingOpen ? -242.0 : -10.0

        UIView.animateWithDuration(0.45, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            
            self.settingTableView.frame.origin.y = borderLabelFrame.origin.y + borderLabelFrame.size.height + yOffset
            self.blackCoverScreen.alpha = blackCoverScreen.isSettingOpen ? 0.0 : 0.45
            
            }, completion: {(val: Bool) -> Void in
                if blackCoverScreen.isSettingOpen {
                    self.settingButton.setImage(UIImage(named: "setting2.png"), forState: UIControlState.Normal)
                    self.settingButton.tintColor = UIColor.blackColor()
                    self.deleteButton.hidden = true
                    
                    self.view.endEditing(true)
                    self.settingTableView.userInteractionEnabled = false
                    blackCoverScreen.isSettingOpen = false
                    
                    if let btn = sender as? UIButton {
                        self.saveChange()
                    }
                } else {
                    self.settingButton.setImage(UIImage(named: "save.png"), forState: UIControlState.Normal)
                    self.settingButton.tintColor = self.FLAT_GREEN_COLOR
                    self.deleteButton.hidden = false
                    self.blackCoverScreen.userInteractionEnabled = true
                    
                    self.settingTableView.userInteractionEnabled = true
                    blackCoverScreen.isSettingOpen = true
                }
                
                self.settingButton.userInteractionEnabled = true
                self.deleteButton.userInteractionEnabled = true
        })
        
        self.settingTableView.changeFontForHeaderTitle()
    }
    
    @IBAction func deletePushed(sender: AnyObject) {
//        println(selectedDayView)
//        self.supplementaryView(shouldDisplayOnDayView: selectedDayView!)

        self.coreDataHandler!.deleteHabit(selected_habit_index)
        selected_habit_index = self.coreDataHandler!.getSelectedHabitIndex()
        self.coreDataHandler!.updateHabit(selected_habit_index, info: NSDictionary(object: true, forKey: "isSelected"))
        
        self.settingPushed(1)
        reflectHabitChange()
        self.calendarView.commitCalendarViewUpdate()
    }
    
    func reflectHabitChange() {
        var info = self.coreDataHandler!.getSelectedHabitInfo(selected_habit_index)
        
        // Habit title update
        self.habitTitle.text = info.valueForKey("title") as? String
        
        // SetingTableView update
        settingTableView.reflectHabitChange(info)
    }
    
    func saveChange() {
        var info = settingTableView.getHabitInfo()
        
        self.coreDataHandler!.updateHabit(selected_habit_index, info: info)
        self.habitTitle.text = info.valueForKey("title") as? String
    }
    
    func failedToFetchData(error: NSError) {
        
    }
    
    func cannotFindSelectedIndex() {
        
    }
}

extension ViewController: SettingTableViewProtocol, BlackCoverScreenProtocol {
    func shouldEndEditing() {
        self.view.endEditing(true)
    }
    
    func blackCoverScreenTapped(sender: AnyObject) {
        if blackCoverScreen.isSettingOpen {
            self.settingPushed(sender)
        } else if blackCoverScreen.isBottomOpen {
            
        }
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
        selectedDayView = dayView
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