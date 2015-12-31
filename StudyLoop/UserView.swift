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
        
        DataService.ds.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            
            let userDict = self.snapshotToDictionary(snapshot)
            self.user = User(dictionary: userDict)
            StateService.ss.setUser(self.user)
            self.configureView()
        })
    }
    
    override func drawRect(rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true
    }
    
    func snapshotToDictionary(snapshot: FDataSnapshot) -> Dictionary<String, AnyObject> {
        var d = Dictionary<String, AnyObject>()
        
        if snapshot.value.objectForKey("name") != nil {
            d["name"] = snapshot.value.objectForKey("name") as? String
        } else {
            d["name"] = ""
        }
        
        if snapshot.value.objectForKey("email") != nil {
            d["email"] = snapshot.value.objectForKey("email") as? String
        } else {
            d["email"] = ""
        }
        
        if snapshot.value.objectForKey("profileImageURL") != nil {
            d["profileImageURL"] = snapshot.value.objectForKey("profileImageURL") as? String
        }
        
        return d
    }
    
    func configureView() {
        emailLabel.text = user.email
        nameLabel.text = user.name

        print("profileImageUrl", user.profileImageURL)
        if let imageUrl = user.profileImageURL {
            print("imgUrl", imageUrl)
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