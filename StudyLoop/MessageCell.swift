//
//  PostCell.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/5/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit
import Alamofire

class MessageCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    
    var message: Message!
    var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.width / 2
        
        profileImg.clipsToBounds = true
        showcaseImg.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(message: Message, img: UIImage?) {
        self.message = message
        self.messageText.text = message.messageText
        self.likesLbl.text = "\(message.likes)"
        
        if message.imageUrl != nil {
            if img != nil {
                self.showcaseImg.image = img
            } else {
                request = Alamofire.request(.GET, message.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        LoopVC.imageCache.setObject(img, forKey: self.message.imageUrl!)
                    }
                })
            }
        } else {
            self.showcaseImg.hidden = true
        }
    }

}
