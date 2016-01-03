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
    
    var item: MenuItem!
    let border = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(item: MenuItem) {
        self.item = item
        self.itemLabel.text = item.title
        
        if item.borderTop {
            // add border
            border.backgroundColor = UIColor.lightGrayColor().CGColor
            border.frame = CGRect(x: 0, y: 0, width: layer.frame.width, height: 0.5)
            layer.addSublayer(border)
        } else {
            border.removeFromSuperlayer()
        }
    }
}
