//
//  CoreDataHandler.swift
//  Habit Log
//
//  Created by Kohei Arai on 5/17/15.
//  Copyright (c) 2015 Kohei Arai. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol CoreDataHandlerDelegate {
    func failedToFetchData(error: NSError)
    func cannotFindSelectedIndex()
}

class CoreDataHandler {
    
    var all_habits = [NSManagedObject]()
    var delegate: CoreDataHandlerDelegate
    
    let managedContext: NSManagedObjectContext
    let logEntity: NSEntityDescription
    let habitEntity: NSEntityDescription
    
    var start: NSDate?
    var end: NSDate?
    
    init(delegate: CoreDataHandlerDelegate) {
        self.delegate = delegate
        
        // Get context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext!
        logEntity = NSEntityDescription.entityForName("Log", inManagedObjectContext: managedContext)!
        habitEntity = NSEntityDescription.entityForName("Habit", inManagedObjectContext: managedContext)!

        
        // Select all habits
        let fetchRequest = NSFetchRequest(entityName: "Habit")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if let result = fetchedResults {
            all_habits = result
        } else {
            self.delegate.failedToFetchData(error!)
        }
    }
    
    func getSelectedHabitIndex() -> Int {
        
        measureStart()
        
        var openHabits = [NSManagedObject]()
        
        for var i = 0; i < all_habits.count; i++ {
            var habit = all_habits[i]
            if habit.valueForKey("isSelected") as! Bool {
                endMeasure("getSelectedHabitIndex")
                return i
            }
            if habit.valueForKey("isSecret") as! Bool == false {
                openHabits.append(habit)
            }
        }
        
        if openHabits.count == 0 {
            var newSelectedIndex = addHabit()
            endMeasure("getSelectedHabitIndex")
            return newSelectedIndex
        }
        
        for var i = 0; i < all_habits.count; i++ {
            if all_habits[i] == openHabits[0] {
                endMeasure("getSelectedHabitIndex")
                return i
            }
        }

        endMeasure("getSelectedHabitIndex")

        return -1
    }
    
    func getSelectedHabitInfo(selected_habit_index: Int) -> NSDictionary {
        measureStart()
        
        var habit = all_habits[selected_habit_index]
        
        var info = NSDictionary(objects: [
            habit.valueForKey("title") as! String,
            habit.valueForKey("isSecret") as! Bool,
            habit.valueForKey("password") as! String
            ], forKeys: ["title", "isSecret", "password"])
        
        endMeasure("getSelectedHabitInfo")
        
        return info
    }
    
    func addHabit() -> Int {
        measureStart()

        let newHabit = NSManagedObject(entity: habitEntity, insertIntoManagedObjectContext: managedContext)
        newHabit.setValue("New Habit", forKey: "title")
        newHabit.setValue(false, forKey: "isSecret")
        newHabit.setValue("", forKey: "password")
        newHabit.setValue(true, forKey: "isSelected")
        newHabit.setValue(NSDate(), forKey: "createdAt")
        
        all_habits.append(newHabit)
        
        endMeasure("addHabit")

        return all_habits.count - 1
    }
    
    func deleteHabit(selected_habit_index: Int) -> Int {
    
        measureStart()
        
        var deletingHabit = all_habits[selected_habit_index]
        var deletingLogs = deletingHabit.mutableSetValueForKey("logs")
        // Need to delete log too
        for log in deletingLogs {
            managedContext.deleteObject(log as! NSManagedObject)
        }
        managedContext.deleteObject(all_habits[selected_habit_index])

        endMeasure("deleteHabit")

        return getSelectedHabitIndex()
    }
    
    func updateHabit(selected_habit_index: Int, info: NSDictionary) {
        
        measureStart()
        
        var habit = all_habits[selected_habit_index]
        
        for (key, value) in info {
            habit.setValue(value, forKey: key as! String)
        }
        
        endMeasure("updateHabit")
        
    }
    
    func addLog(selected_habit_index: Int, year: Int, month: Int, day: Int) {
        
        measureStart()
        
        let newLog = NSManagedObject(entity: logEntity, insertIntoManagedObjectContext: managedContext)
        newLog.setValue(year, forKey: "year")
        newLog.setValue(month, forKey: "month")
        newLog.setValue(day, forKey: "day")
        
        // Add log
        var logs = all_habits[selected_habit_index].mutableSetValueForKey("logs")
        logs.addObject(newLog)

        
        endMeasure("addLog")
    }
    
    func deleteLog(selected_habit_index: Int, year: Int, month: Int, day: Int) {
        
        measureStart()
        
        var logs = all_habits[selected_habit_index].mutableSetValueForKey("logs")

        var predicate = NSPredicate(format: "year == %@ AND month == %@ AND day == %@", year, month, day)
        var filteredLogs = logs.filteredSetUsingPredicate(predicate)

        for log in filteredLogs {
            managedContext.deleteObject(log as! NSManagedObject)
        }

        
        endMeasure("deleteLog")
    }
}

extension CoreDataHandler {
    func measureStart() {
        start = NSDate()
    }
    
    func endMeasure(title: String) {
        end = NSDate()
        println("\(title): \(end!.timeIntervalSinceDate(start!))")
    }
    
    func findNextSelectedHabitIndex() -> Int {
        return 1
    }
}