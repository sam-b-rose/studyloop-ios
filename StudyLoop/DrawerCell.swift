//
//  DrawerCell.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/29/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit

class DrawerCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var menuIcon: UILabel!
    
    var item: MenuItem!
    let border = CALayer()
    let selectedBorder = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(item: MenuItem) {
        self.item = item
        self.selectionStyle = .None
        itemLabel.text = item.title
        
        // Icon Defaults
        menuIcon.hidden = true
        menuIcon.textColor = SL_WHITE
        menuIcon.font = UIFont.ioniconOfSize(20)
        
        selectedBorder.backgroundColor = SL_GREEN.CGColor
        selectedBorder.frame = CGRect(x: 0, y: 0, width: 5, height: layer.frame.height)
        layer.addSublayer(selectedBorder)
        
        border.backgroundColor = SL_GRAY.colorWithAlphaComponent(0.35).CGColor
        border.frame = CGRect(x: 15, y: 0, width: layer.frame.width - 15, height: 0.5)
        // layer.addSublayer(border)
        
        if item.title == "Add Course" {
            menuIcon.hidden = false
            menuIcon.text = String.ioniconWithCode("ion-plus")
        } else if item.title == "Settings" {
            menuIcon.hidden = false
            menuIcon.text = String.ioniconWithCode("ion-ios-gear")
        } else {
            let courses = NotificationService.noti.notifications.filter { $0.courseId == item.courseId }
            if courses.count > 0 {
                menuIcon.hidden = false
                menuIcon.textColor = SL_RED
                menuIcon.text = String.ioniconWithCode("ion-record")
            }
        }
        
        if let courseId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) as? String where item.courseId != "" && courseId == item.courseId {
            selectedBorder.hidden = false
            self.backgroundColor = UIColor(red:0.09, green:0.1, blue:0.11, alpha:1)
        } else {
            selectedBorder.hidden = true
            self.backgroundColor = SL_BLACK
        }
    }
}
