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

class MemberCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    
    var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userAvatar.layer.cornerRadius = 20
        userAvatar.clipsToBounds = true
        userAvatar.backgroundColor = SL_LIGHT
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureCell(var userName: String?, profileImageURL: String?) {
        self.selectionStyle = .None
        
        if userName != nil {
            nameLabel.text = userName
        } else {
            // TODO: Change to prevent initial loading glitch
            nameLabel.text = "Removed User"
            userName = "Removed User"
        }
        
        
        let nameArray = userName!.characters.split{ $0 == " " }.map(String.init)

        var initialsArray = [String]()
        for name in nameArray {
            if let letter = name.characters.first {
                initialsArray.append(String(letter))
            }
        }
        
        
        let initials = initialsArray.joinWithSeparator("")
        initialsLabel.text = initials
        
        if profileImageURL != nil {
            initialsLabel.hidden = true
            if let img = LoopVC.imageCache.objectForKey(profileImageURL!) as? UIImage {
                self.userAvatar.image = img
            } else {
                request = Alamofire.request(.GET, profileImageURL!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.userAvatar.image = img
                        MembersVC.imageCache.setObject(img, forKey: profileImageURL!)
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

}
