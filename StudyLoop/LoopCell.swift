//
//  LoopCell.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/2/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class LoopCell: UITableViewCell {

//    @IBOutlet weak var loopName: UILabel!
//    
//    var loop: Loop!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//    
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
//    
//    func configureCell(loop: Loop) {
//        self.loop = loop
//        self.loopName.text = loop.subject
//    }
    
    lazy var loopLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 17)
        label.textColor = SL_BLACK
        return label
    }()
    
    lazy var lastLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 17)
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
        self.addSubview(self.lastLabel)
        
        loopLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
        }
        
        lastLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(loopLabel.snp_bottom).offset(1)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.bottom.equalTo(self).offset(-10)
        }
    }

}
