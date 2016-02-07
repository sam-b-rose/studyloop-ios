//
//  FancyHeaderView.swift
//  StudyLoop
//
//  Created by Sam Rose on 2/5/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class ImageConfirmView: UIView {
    
    var imageView: UIImageView!
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRectMake(10, 10, 40, 40))
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.cornerRadius = 5.0
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        label = UILabel(frame: CGRectMake(60, 20, 200, 20))
        label.text = "Confirm"
        label.textColor = SL_WHITE
        label.font = UIFont(name: "Noto Sans", size: 17)
        label.backgroundColor = UIColor.clearColor()
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureImageConfirm(image: UIImage!) {
        imageView.image = image
    }

}
