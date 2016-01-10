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
    @IBOutlet weak var nameLabel: UILabel!
    
    var user: User!
    let border = CALayer()
    var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "viewTapped:")
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        self.userInteractionEnabled = true
        
        // add border
        border.backgroundColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRect(x: 0, y: self.layer.frame.height, width: self.layer.frame.width, height: 0.5)
        layer.addSublayer(border)
        
        DataService.ds.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                self.user = User(uid: snapshot.key, dictionary: userDict)
                self.configureView()
            }
        })
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
     
    func viewTapped(sender: UITapGestureRecognizer) {
        // go to profile
        print("view tapped: go to profile")
    }
    
    
}