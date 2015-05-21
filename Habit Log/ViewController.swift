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
    @IBOutlet weak var menuButton: UIButton!
    
    let FLAT_GREEN_COLOR: UIColor = UIColor(red: 0.180, green: 0.800, blue: 0.443, alpha: 0.80)

    var settingTableView: SettingTableView = SettingTableView()
    var blackCoverScreen: BlackCoverScreen = BlackCoverScreen()
    var habitMenu: HabitMenu?
    var bottomView: BottomMenu?
    
    var animationFinished = true
    var isSettingOpen = false
    var isBottomButtonOpen = false
    
    var coreDataHandler: CoreDataHandler?
    var selected_habit_index: Int = -1
    var selectedDayView: CVCalendarDayView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Not sure if this is the right place to initiate coreDataHandler
        self.coreDataHandler = CoreDataHandler(delegate: self)
        selected_habit_index = self.coreDataHandler!.getSelectedHabitIndex()
        self.habitTitle.text = self.coreDataHandler!.getSelectedHabitInfo(selected_habit_index).valueForKey("title") as? String
        
        self.monthLabel.text = CVDate(date: NSDate()).globalDescription
        self.deleteButton.hidden = true
        self.deleteButton.tintColor = UIColor(red: 1, green: 0.231373, blue: 0.188235, alpha: 0.8)
        
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
         setUpOtherViewComponents()
         reflectHabits()
    }
    
    func setUpOtherViewComponents() {
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
        
        habitMenu = HabitMenu(frame: CGRectMake(-200, 28, 200, self.view.frame.size.height - 28), coreDataHandler: self.coreDataHandler!)
        habitMenu!.habitMenuDelegate = self
        
        bottomView = BottomMenu(frame: CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 100))
        bottomView?.delegate = self
        
        self.bringSubviewsToFront([self.habitTitle, self.borderLabel, whiteLabel, settingButton, deleteButton, menuButton])
        self.view.insertSubview(settingTableView, belowSubview: self.habitTitle)
        self.view.insertSubview(blackCoverScreen, belowSubview: settingTableView)
        self.view.addSubview(habitMenu!)
        self.view.addSubview(bottomView!)
        
        self.menuButton.alpha = 1
        self.menuButton.hidden = false
    }
    
    func reflectHabits() {
        var info = self.coreDataHandler!.getSelectedHabitInfo(selected_habit_index)
        
        self.habitTitle.text = info.valueForKey("title") as? String
        settingTableView.reflectHabitChange(info)
    }
    
    // Code here is really messy. Refactor later.
    @IBAction func settingPushed(sender: AnyObject) {
        self.deleteButton.userInteractionEnabled = false
        self.settingButton.userInteractionEnabled = false
        
        self.blackCoverScreen.userInteractionEnabled = false
        
        var borderLabelFrame = self.borderLabel.frame
        var yOffset: CGFloat = blackCoverScreen.isSettingOpen ? -242.0 : -10.0

        UIView.animateWithDuration(0.45, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            
            self.settingTableView.frame.origin.y = borderLabelFrame.origin.y + borderLabelFrame.size.height + yOffset
            self.blackCoverScreen.alpha = self.blackCoverScreen.isSettingOpen ? 0.0 : 0.45
            self.habitMenu!.frame.origin.x = -200
            self.bottomView!.frame.origin.y = self.view.frame.size.height
            
            }, completion: {(val: Bool) -> Void in
                var imageName = self.blackCoverScreen.isSettingOpen ? "setting2.png" : "save.png"
                var tintColor = self.blackCoverScreen.isSettingOpen ? UIColor.blackColor() : self.FLAT_GREEN_COLOR
                
                self.settingButton.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
                self.settingButton.tintColor = tintColor
                self.settingButton.userInteractionEnabled = true
                
                self.deleteButton.userInteractionEnabled = true
                self.deleteButton.hidden = self.blackCoverScreen.isSettingOpen
                self.view.endEditing(true)
                
                if let btn = sender as? UIButton where self.blackCoverScreen.isSettingOpen {
                    var info = self.settingTableView.getHabitInfo()
                    
                    self.coreDataHandler!.updateHabit(self.selected_habit_index, info: info)
                    self.habitTitle.text = info.valueForKey("title") as? String
                    self.habitMenu?.reloadData()
                }
                
                self.blackCoverScreen.isSettingOpen = !self.blackCoverScreen.isSettingOpen
                
                self.settingTableView.userInteractionEnabled = self.blackCoverScreen.isSettingOpen
                self.blackCoverScreen.userInteractionEnabled = self.blackCoverScreen.isSettingOpen
                self.menuButton.hidden = self.blackCoverScreen.isSettingOpen
        })
        
        self.settingTableView.changeFontForHeaderTitle()
    }
    
    @IBAction func deletePushed(sender: AnyObject) {
        self.coreDataHandler!.deleteHabit(selected_habit_index)
        selected_habit_index = self.coreDataHandler!.getSelectedHabitIndex()
        self.coreDataHandler!.updateHabit(selected_habit_index, info: NSDictionary(object: true, forKey: "isSelected"))
        
        self.settingPushed(1)
        self.habitMenu?.reloadData()
        reflectHabits()
        self.calendarView.commitCalendarViewUpdate()
    }
    
    @IBAction func menuPushed(sender: AnyObject) {
        self.blackCoverScreen.userInteractionEnabled = false
        UIView.animateWithDuration(0.45, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.habitMenu!.frame.origin.x = 0
            self.blackCoverScreen.alpha = 0.45
            self.bottomView!.frame.origin.y = self.view.frame.size.height
            }, completion: {(val: Bool) -> Void in
                self.blackCoverScreen.userInteractionEnabled = true
        })
        
    }
    
    func failedToFetchData(error: NSError) {
        
    }
    
    func cannotFindSelectedIndex() {
        
    }
}

extension ViewController: SettingTableViewProtocol, BlackCoverScreenProtocol, HabitMenuProtocol, BottomMenuProtocol {
    func shouldEndEditing() {
        self.view.endEditing(true)
    }
    
    func blackCoverScreenTapped(sender: AnyObject) {
        self.blackCoverScreen.userInteractionEnabled = false
        UIView.animateWithDuration(0.45, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.habitMenu!.frame.origin.x = -200
            self.blackCoverScreen.alpha = 0.0
            }, completion: {(val: Bool) -> Void in
                self.blackCoverScreen.userInteractionEnabled = true
        })
        
        if blackCoverScreen.isSettingOpen {
            self.settingPushed(sender)
        }
    }
    
    func shouldUpdateLog() {
        
    }
    
    func cellSelected(selected_index: Int) {
        self.coreDataHandler?.updateHabit(selected_habit_index, info: NSDictionary(dictionary: ["isSelected": false]))
        
        selected_habit_index = selected_index
        
        if selected_habit_index == self.coreDataHandler?.all_habits.count {
            self.coreDataHandler?.addHabit()
        } else {
            self.coreDataHandler?.updateHabit(selected_habit_index, info: ["isSelected": true])
        }
        printFrame("calendarMenu", frame: self.menuView!.frame)
        printFrame("presentedMonthView", frame: self.menuView!.frame)
        printFrame("calendarView", frame: self.calendarView!.contentController!.presentedMonthView.frame)
        
        
        self.calendarView!.contentController!.presentedMonthView.reloadViewsWithRect(CGRectMake(0, 0, self.calendarView!.frame.size.width, self.calendarView!.frame.size.height))
//        self.calendarView!.contentController!.presentedMonthView.updateAppearance(CGRectMake(0, 0, self.calendarView!.frame.size.width, self.calendarView!.frame.size.height))
//        self.calendarView!.contentController!.presentedMonthView.updateInteractiveView()
//        self.calendarView.commitCalendarViewUpdate()

        printFrame("calendarMenu", frame: self.menuView!.frame)
        printFrame("presentedMonthView", frame: self.menuView!.frame)
        printFrame("calendarView", frame: self.calendarView!.frame)
        self.reflectHabits()
    }
    
    func buttonPushed() {
        let date = selectedDayView!.date
        if self.coreDataHandler!.checkSupplementaryView(selected_habit_index, year: date.year, month: date.month, day: date.day) {
            
            self.bottomView?.setButtonOff()
            self.coreDataHandler?.deleteLog(selected_habit_index, year: date.year, month: date.month, day: date.day)
            selectedDayView?.viewWithTag(10)?.removeFromSuperview()
        } else {
            self.bottomView?.setButtonOn()
            self.coreDataHandler?.addLog(selected_habit_index, year: date.year, month: date.month, day: date.day)
            selectedDayView!.supplementarySetup()
            selectedDayView!.circleView?.fillColor = UIColor.clearColor()
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
        
        let today = NSDate()
        let currentMonth = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitMonth, fromDate: today)

        if selectedDayView?.date.month == dayView.date.month || dayView.date.month == currentMonth {
            bottomView!.showBottom()
        } else {
            bottomView!.hideBottom()
        }
        
        if self.supplementaryView(shouldDisplayOnDayView: dayView) {
            bottomView!.setButtonOn()
        } else {
            bottomView!.setButtonOff()
        }
        
        selectedDayView = dayView
        println("\(calendarView.presentedDate.commonDescription) is selected!")
    }
    
    func presentedDateUpdated(date: CVDate) {
        if monthLabel.text != date.globalDescription && self.animationFinished {
            self.bottomView?.hideBottom()
            
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
        var date = dayView.date
        return self.coreDataHandler!.checkSupplementaryView(selected_habit_index, year: date.year, month: date.month, day: date.day)
    }

    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        var circle = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        circle.tag = 10
        circle.fillColor = FLAT_GREEN_COLOR
        
        dayView.dayLabel!.textColor = UIColor.whiteColor()

        return circle
    }
}

extension ViewController {
    func printFrame(name: String, frame: CGRect) {
        println("\(name) x: \(frame.origin.x), y: \(frame.origin.y), width: \(frame.size.width), height: \(frame.size.height)")
    }
    
    func bringSubviewsToFront(subviews: [UIView]) {
        for view in subviews {
            self.view.bringSubviewToFront(view)
        }
    }
}