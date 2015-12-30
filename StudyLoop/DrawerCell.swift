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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(item: MenuItem) {
        self.item = item
        self.itemLabel.text = item.title
    }

}
