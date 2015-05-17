//
//  HabitImageHandler.swift
//  Habit Log
//
//  Created by Kohei Arai on 5/17/15.
//  Copyright (c) 2015 Kohei Arai. All rights reserved.
//

import Foundation
import UIKit

protocol HabitImageHandlerDelegate {
    func imageRecieved(image: UIImage)
}

class HabitImageHandler {
//    var delegate
    
    let IMAGE_SIZE = 150
    
    init() {
        
    }
    
    func getHabitImageAtIndex(habit_index: Int) -> UIImage{
        // Implement later
        return UIImage()
    }
    
    func updateHabitImageAtIndex(habit_index: Int, calendarView: UIView) -> UIImage {
        // Implement later
        return UIImage()
    }
}