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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(item: MenuItem) {
        self.item = item
        self.itemLabel.text = item.title
        
        if item.title == "Add Course" {
            menuIcon.font = UIFont.ioniconOfSize(17)
            menuIcon.text = String.ioniconWithCode("ion-plus")
        } else if item.title == "Settings" {
            menuIcon.font = UIFont.ioniconOfSize(17)
            menuIcon.text = String.ioniconWithCode("ion-ios-gear")
        } else {
            menuIcon.text = ""
        }
        
        border.backgroundColor = SL_GRAY.colorWithAlphaComponent(0.3).CGColor
        border.frame = CGRect(x: 15, y: 0, width: layer.frame.width - 15, height: 0.5)
        layer.addSublayer(border)
    }
}
