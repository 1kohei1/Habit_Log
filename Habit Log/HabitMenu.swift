//
//  HabitMenu.swift
//  Habit Log
//
//  Created by Kohei Arai on 5/18/15.
//  Copyright (c) 2015 Kohei Arai. All rights reserved.
//

import UIKit

protocol HabitMenuProtocol {
    func cellSelected(selected_index: Int)
}

class HabitMenu: UITableView {

    var selected_habit_index: Int = -1
    var coreDataHandler: CoreDataHandler?
    var habitImageHandler: HabitImageHandler?
    var habitMenuDelegate: HabitMenuProtocol?
    
    init(frame: CGRect, coreDataHandler: CoreDataHandler) {
        super.init(frame: frame, style: UITableViewStyle.Plain)
        
        self.delegate = self
        self.dataSource = self
        
        self.coreDataHandler = coreDataHandler
        
        self.habitImageHandler = HabitImageHandler()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension HabitMenu: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coreDataHandler!.all_habits.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel!.text = self.coreDataHandler?.all_habits[indexPath.row].valueForKey("title") as? String
        cell?.textLabel!.font = UIFont(name: "Avenir", size: 20)
        cell?.imageView!.image  = self.habitImageHandler?.getHabitImageAtIndex(indexPath.row)
        
        if self.coreDataHandler?.getSelectedHabitIndex() == indexPath.row {
            cell?.textLabel!.font = UIFont(name: "Avenir-Heavy", size: 20)
        }
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.Gray
        
        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.habitMenuDelegate!.cellSelected(indexPath.row)
    }
}