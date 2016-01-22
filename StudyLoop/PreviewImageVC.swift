//
//  PreviewImageVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/22/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class PreviewImageVC: UIViewController {

    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var captionField: MaterialTextField!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        sendBtn.titleLabel?.font = UIFont.ioniconOfSize(26)
        sendBtn.setTitle(String.ioniconWithName(.AndroidSend), forState: .Normal)
        
        cancelBtn.titleLabel?.font = UIFont.ioniconOfSize(26)
        cancelBtn.setTitle(String.ioniconWithName(.Close), forState: .Normal)
        
        previewImageView.image = image
        previewImageView.layer.cornerRadius = 8.0
        previewImageView.clipsToBounds = true
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func didTapCancelBtn(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapSendBtn(sender: AnyObject) {
        print("Send Message with caption", captionField.text)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
