//
//  LoopMessageCell.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/8/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

class LoopMessageCell: UITableViewCell {
    
    var request: Request?
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 17)
        label.textColor = UIColor(red:0, green:0.87, blue:0.74, alpha:1)
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 17)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var userAvatar: UIImageView = {
        let avatar = UIImageView(image: UIImage(named: "owl-light-bg"))
        avatar.layer.cornerRadius = 15
        avatar.clipsToBounds = true
        return avatar
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
        self.addSubview(self.nameLabel)
        self.addSubview(self.bodyLabel)
        self.addSubview(self.userAvatar)
        
        userAvatar.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(15)
            make.left.equalTo(self).offset(20)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(self.userAvatar.snp_right).offset(10)
            make.right.equalTo(self).offset(-20)
        }
        
        bodyLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(nameLabel.snp_bottom).offset(1)
            make.left.equalTo(self.userAvatar.snp_right).offset(10)
            make.right.equalTo(self).offset(-20)
            make.bottom.equalTo(self).offset(-10)
        }
    }
    
    func configureCell(text: String, name: String, imageUrl: String?, image: UIImage?) {
        nameLabel.text = name
        bodyLabel.text = text
        
        if image != nil {
            self.userAvatar.image = image
        } else if imageUrl != nil {
            request = Alamofire.request(.GET, imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                if err == nil {
                    let img = UIImage(data: data!)!
                    self.userAvatar.image = img
                    MessageVC.imageCache.setObject(img, forKey: imageUrl!)
                } else {
                    print("There was an error!", err)
                }
            })
        }
    }
}
