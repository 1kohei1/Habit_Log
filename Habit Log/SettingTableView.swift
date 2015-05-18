//
//  SettingTableView.swift
//  Habit Log
//
//  Created by Kohei Arai on 5/17/15.
//  Copyright (c) 2015 Kohei Arai. All rights reserved.
//

import UIKit

protocol SettingTableViewProtocol {
    func shouldEndEditing()
}

class SettingTableView: UIView {

    var settingTableView: UITableView = UITableView()
    var delegate: SettingTableViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        settingTableView = UITableView(frame: CGRectMake(0, 0, frame.size.width, 244), style: UITableViewStyle.Grouped)
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.reloadData()
        
        self.addSubview(settingTableView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// Mark: - Delegate

extension SettingTableView: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "HABIT TITLE"
        } else {
            return "SECRET"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("Cell1") as? UITableViewCell
        } else {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("Cell2") as? UITableViewCell
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("Cell3") as? UITableViewCell
            }
        }
        
        if cell == nil {
            if indexPath.section == 0 {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell2")
                
                var textField = UITextField(frame: CGRectMake(0, 0, frame.size.width, cell!.frame.size.height))
                textField.tag = 9
                textField.placeholder = "Enter Title"
                textField.font = UIFont(name: "Avenir", size: 20)
                textField.textAlignment = NSTextAlignment.Center
                textField.borderStyle = UITextBorderStyle.None
                textField.returnKeyType = UIReturnKeyType.Done
                textField.delegate = self
                
                cell?.addSubview(textField)
            } else {
                var titleLabel = UILabel(frame: CGRectMake(16, 0, frame.size.width / 2, 44))
                titleLabel.font = UIFont(name: "Avenir", size: 20)
                titleLabel.tag = 11
                
                if indexPath.row == 0 {
                    cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell2")
                    
                    titleLabel.text = "Secret"
                    cell!.addSubview(titleLabel)
                    
                    var secretSwitch = UISwitch(frame: CGRectMake(frame.size.width - 16 - 51, 6.5, 51, 31))
                    secretSwitch.tag = 10
                    secretSwitch.addTarget(self, action: "secretSwitchChanged:", forControlEvents: UIControlEvents.ValueChanged)
                    cell!.addSubview(secretSwitch)
                } else {
                    cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell3")
                    
                    titleLabel.text = "Password"
                    titleLabel.alpha = 0.2
                    cell!.addSubview(titleLabel)
                    
                    var textField = UITextField(frame: CGRectMake(frame.size.width / 2, 0, frame.size.width / 2, cell!.frame.size.height))
                    textField.tag = 12
                    textField.placeholder = "Enter Password"
                    textField.secureTextEntry = true
                    textField.font = UIFont(name: "Avenir", size: 20)
                    textField.textAlignment = NSTextAlignment.Center
                    textField.borderStyle = UITextBorderStyle.None
                    textField.returnKeyType = UIReturnKeyType.Done
                    textField.userInteractionEnabled = false
                    textField.delegate = self
                    
                    cell?.addSubview(textField)
                }
            }
        }
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell!
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.delegate?.shouldEndEditing()
        return false
    }
    
    func secretSwitchChanged(sender:UISwitch!) {
        var indexPath = NSIndexPath(forRow: 1, inSection: 1)
        var cell = self.settingTableView.cellForRowAtIndexPath(indexPath)
        
        if sender.on {
            cell?.viewWithTag(11)?.alpha = 1
            cell?.viewWithTag(12)?.alpha = 1
            cell?.viewWithTag(12)?.userInteractionEnabled = true
        } else {
            cell?.viewWithTag(11)?.alpha = 0.2
            cell?.viewWithTag(12)?.alpha = 0.2
            cell?.viewWithTag(12)?.userInteractionEnabled = false
        }
    }
}

// Mark: - Other helping function

extension SettingTableView {
    func reflectHabitChange(info: NSDictionary) {
        var cell: UITableViewCell?
        cell = settingTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        var titleTextField = cell!.viewWithTag(9) as! UITextField
        titleTextField.text = info.valueForKey("title") as? String
        
        cell = settingTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))
        var secretSwitch = cell!.viewWithTag(10) as! UISwitch
        secretSwitch.setOn(info.valueForKey("isSecret") as! Bool, animated: false)
        
        cell = settingTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))
        var passwordTextField = cell!.viewWithTag(12) as! UITextField
        passwordTextField.text = info.valueForKey("password") as? String
        
    }
    
    func getHabitInfo() -> NSDictionary {
        var cell: UITableViewCell?
        cell = settingTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        var titleTextField = cell!.viewWithTag(9) as! UITextField
        
        cell = settingTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))
        var secretSwitch = cell!.viewWithTag(10) as! UISwitch
        
        cell = settingTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))
        var passwordTextField = cell!.viewWithTag(12) as! UITextField
        
        var keys = ["title", "isSecret", "password"]
        var values = [titleTextField.text, secretSwitch.on, passwordTextField.text]

        return NSDictionary(objects: values as [AnyObject], forKeys: keys)
    }
    
    func changeFontForHeaderTitle() {
        var titleLabel = settingTableView.headerViewForSection(0)
        if titleLabel != nil {
            titleLabel!.textLabel.font = UIFont(name: "Avenir-Medium", size: 13)
        }
        titleLabel = settingTableView.headerViewForSection(1)
        if titleLabel != nil {
            titleLabel!.textLabel.font = UIFont(name: "Avenir-Medium", size: 13)
        }
    }
}