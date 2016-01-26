//
//  LoopCell.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/2/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class LoopCell: UITableViewCell {
    
    lazy var border: UIView = {
        let border = UIView()
        border.backgroundColor = SL_GRAY.colorWithAlphaComponent(0.3)
        border.frame = CGRect(x: 15, y: 0, width: self.frame.width, height: 0.5)
        return border
    }()
    
    lazy var loopLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 17)
        label.textColor = SL_BLACK
        return label
    }()
    
    lazy var newMessageInidcator: UILabel = {
        let label = UILabel()
        label.textColor = SL_RED
        label.font = UIFont.ioniconOfSize(17)
        label.text = String.ioniconWithName(.Record)
        return label
    }()
    
    lazy var lastLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 10)
        label.textColor = SL_GRAY
        label.numberOfLines = 1
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 10)
        label.textColor = SL_GRAY
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
    }
    
    // We won’t use this but it’s required for the class to compile
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureSubviews() {
        self.addSubview(self.loopLabel)
        self.addSubview(self.newMessageInidcator)
        self.addSubview(self.lastLabel)
        self.addSubview(self.dateLabel)
        self.addSubview(border)

        
        loopLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self.dateLabel.snp_left).offset(-20)
        }
        
        lastLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.loopLabel.snp_bottom).offset(5)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self.newMessageInidcator.snp_left).offset(-20).priorityMedium()
            make.bottom.equalTo(self).offset(-10)
            make.width.lessThanOrEqualTo(self).offset(-80)
            make.height.greaterThanOrEqualTo(20)
        }
        
        newMessageInidcator.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.loopLabel.snp_bottom).offset(5).priorityHigh()
            make.right.equalTo(self).offset(-35).priorityHigh()
            // make.left.equalTo(self.lastLabel.snp_right).offset(20).priorityHigh()
        }
        
        dateLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(10).priorityHigh()
            make.right.equalTo(self).offset(-35).priorityHigh()
            //make.left.equalTo(self.loopLabel.snp_right).offset(20)
            //make.width.lessThanOrEqualTo(100)
        }
    }
    
    func configureCell(loop: Loop) {
        loopLabel.text = loop.subject
        lastLabel.text = loop.lastMessage
        newMessageInidcator.hidden = true
        backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        
        if loop.lastMessageTime != nil {
            let date = TimeUtils.tu.dayStringFromTime(loop.lastMessageTime!)
            dateLabel.text = date
        } else {
            dateLabel.text = ""
        }
 
        let loopNotifications = NotificationService.noti.notifications.filter { $0.loopId == loop.uid }
        print(loopNotifications.count)
        if loopNotifications.count > 0 {
            if loopNotifications[0].type == LOOP_MESSAGE_RECEIVED {
                newMessageInidcator.hidden = false
            } else if loopNotifications[0].type == LOOP_CREATED {
                self.backgroundColor = SL_LIGHT
            }
        }
    }

}
