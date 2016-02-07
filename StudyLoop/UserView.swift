//
//  UserView.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/28/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class UserView: UIView {
    
    @IBOutlet weak var settingsIcon: UILabel!
    @IBOutlet weak var profileImage: UserImage!
    @IBOutlet weak var nameLabel: UILabel!
    
    var user: User!
    var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        settingsIcon.font = UIFont.ioniconOfSize(20)
        settingsIcon.text = String.ioniconWithCode("ion-ios-gear")

        user = UserService.us.currentUser
        configureView()
    }
    
    override func drawRect(rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true
    }
    
    func configureView() {
        nameLabel.text = user.name
        
        if let imageUrl = user.profileImageURL {
            self.request = Alamofire.request(.GET, imageUrl).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                if err == nil {
                    let img = UIImage(data: data!)!
                    self.profileImage.image = img
                    DrawerVC.imageCache.setObject(img, forKey: imageUrl)
                } else {
                    print("There was an error!", err)
                }
            })
        }
    }
}