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
    
    @IBOutlet weak var profileImage: UserImage!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var user: User!
    var likeRef: Firebase!
    var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "viewTapped:")
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        self.userInteractionEnabled = true
        
        self.user = StateService.ss.CURRENT_USER
        self.configureView()
    }
    
    override func drawRect(rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true
    }
    
    func configureView() {
        emailLabel.text = user.email
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
    
    func viewTapped(sender: UITapGestureRecognizer) {
        // go to profile
        print("view tapped: go to profile")
    }
    
    
}