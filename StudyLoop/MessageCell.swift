//
//  MessageCell.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/5/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class MessageCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var messageImg: UIImageView!
    @IBOutlet weak var textValue: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    var message: Message!
    var likeRef: Firebase!
    var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.width / 2
        profileImg.clipsToBounds = true
        
        messageImg.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(message: Message, img: UIImage?) {
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(message.messageKey)

        self.message = message
        self.textValue.text = message.textValue
        self.likesLbl.text = "\(message.likes)"
        self.messageImg.hidden = true
        
        if message.attachmentUrl != nil {
            if img != nil {
                self.messageImg.image = img
                self.messageImg.hidden = false
            } else {
                request = Alamofire.request(.GET, message.attachmentUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.messageImg.image = img
                        self.messageImg.hidden = false
                        LoopVC.imageCache.setObject(img, forKey: self.message.attachmentUrl!)
                    } else {
                        print("There was an error!", err)
                    }
                })
            }
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "heart-o")
            } else {
                self.likeImage.image = UIImage(named: "heart")
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "heart")
                self.message.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "heart-o")
                self.message.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
    }
}
