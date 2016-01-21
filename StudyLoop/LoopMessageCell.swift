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
        label.textColor = SL_GREEN
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 17)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var initialsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 17)
        label.textColor = SL_CORAL
        label.textAlignment = .Center
        return label
    }()
    
    lazy var userAvatar: UIImageView = {
        let avatar = UIImageView(image: UIImage(named: "owl-light-bg"))
        avatar.layer.cornerRadius = 20
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
        self.addSubview(self.initialsLabel)
        
        userAvatar.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(18)
            make.left.equalTo(self).offset(20)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        initialsLabel.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.userAvatar)
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
    
    func configureCell(text: String, name: String?, imageUrl: String?) {
        self.selectionStyle = .None
        bodyLabel.text = text
        
        if name != nil {
            
            // TODO: Users initials not working
            nameLabel.text = name
            let initialsArr = name!.characters.split{$0 == " "}.map(String.init)
            let firstInitial = getFirstLetter(initialsArr[0])
            var secondInitial = ""
            
            if initialsArr.count > 1 {
                secondInitial = getFirstLetter(initialsArr[1])
            }
            
            let initials = "\(firstInitial)\(secondInitial)"
            initialsLabel.text = initials
//            print("Initials:", initials)
        } else {
            nameLabel.text = "Removed User"
            initialsLabel.text = "RM"
        }
        
        if imageUrl != nil {
            initialsLabel.hidden = true
            if let img = LoopVC.imageCache.objectForKey(imageUrl!) as? UIImage {
                self.userAvatar.image = img
            } else {
                request = Alamofire.request(.GET, imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.userAvatar.image = img
                        LoopVC.imageCache.setObject(img, forKey: imageUrl!)
                    } else {
                        print("There was an error!", err)
                    }
                })
            }
        } else {
            initialsLabel.hidden = false
            userAvatar.backgroundColor = SL_LIGHT
            userAvatar.image = nil
        }
    }
    
    func getFirstLetter(str: String) -> String {
        let index = str.startIndex.advancedBy(0)
        return str.substringToIndex(index)
    }
}
