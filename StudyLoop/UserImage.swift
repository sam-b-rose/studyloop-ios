//
//  UserImage.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/25/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit
import Alamofire

class UserImage: UIImageView {
    
    var request: Request?
    
    override func awakeFromNib() {
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
    }
    
    func getImage(user: User) {
        if let imageUrl = user.profileImageURL {
            self.request = Alamofire.request(.GET, imageUrl).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                if err == nil {
                    let img = UIImage(data: data!)!
                    self.image = img
                } else {
                    print("There was an error getting the profile picture!", err)
                }
            })
        }
    }
}