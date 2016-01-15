//
//  LoopMemberCell.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/14/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

class LoopMemberCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    
    var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userAvatar.layer.cornerRadius = 20
        userAvatar.clipsToBounds = true
        userAvatar.backgroundColor = UIColor(red:0.87, green:0.94, blue:0.94, alpha:1)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureCell(user: User) {
        nameLabel.text = user.name
        let initialsArr = user.name.characters.split{$0 == " "}.map(String.init)
        let firstInitial = getFirstLetter(initialsArr[0])
        var secondInitial = ""
        if initialsArr.count > 1 {
            secondInitial = getFirstLetter(initialsArr[1])
        }
        let initials = "\(firstInitial)\(secondInitial)"
        initialsLabel.text = initials
        print(initials)
        
        if user.profileImageURL != nil {
            initialsLabel.hidden = true
            if let img = LoopVC.imageCache.objectForKey(user.profileImageURL!) as? UIImage {
                self.userAvatar.image = img
            } else {
                request = Alamofire.request(.GET, user.profileImageURL!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.userAvatar.image = img
                        LoopMembersVC.imageCache.setObject(img, forKey: user.profileImageURL!)
                    } else {
                        print("There was an error!", err)
                    }
                })
            }
        } else {
            initialsLabel.hidden = false
            userAvatar.image = nil
        }
    }
    
    func getFirstLetter(str: String) -> String {
        let index = str.startIndex.advancedBy(0)
        return str.substringToIndex(index)
    }
    
    /* ---- */


}
