//
//  DrawerVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/25/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import KYDrawerController

class DrawerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UserImage!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var user: User?
    var request: Request?
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // set user data
        DataService.ds.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            
            // move to a user object maybe??
            if let name = snapshot.value.objectForKey("name") as? String {
                print("Name", name)
                self.nameLabel.text = name
            }
            
            if let email = snapshot.value.objectForKey("email") as? String {
                print("Email", email)
                self.emailLabel.text = email
            }
            
            if let imageUrl = snapshot.value.objectForKey("profileImgURL") as? String {
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
        })
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let drawerController = navigationController?.parentViewController as? KYDrawerController {
            let mainNavigation = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainNavigation") as! UINavigationController
            let backgroundColor: UIColor
            switch indexPath.row {
            case 0:
                backgroundColor = UIColor.redColor()
            case 1:
                backgroundColor = UIColor.blueColor()
            default:
                backgroundColor = UIColor.whiteColor()
            }
            mainNavigation.topViewController?.view.backgroundColor = backgroundColor
            drawerController.mainViewController = mainNavigation
            drawerController.setDrawerState(.Closed, animated: true)
        }
    }
    
}
