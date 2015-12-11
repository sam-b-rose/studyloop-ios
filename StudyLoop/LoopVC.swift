//
//  LoopVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/5/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class LoopVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageField: MaterialTextField!
    @IBOutlet weak var imageSelectorBtn: UIImageView!
    
    var messages = [Message]()
    var imageSelected = false
    static var imageCache = NSCache()
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        tableView.estimatedRowHeight = 432
        
        DataService.ds.REF_LOOP.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            
            self.messages = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    // print("SNAP: \(snap)")
                    
                    if let messageDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let message = Message(messageKey: key, dictionary: messageDict)
                        self.messages.append(message)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as? MessageCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url =  message.imageUrl {
                img = LoopVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(message, img: img)
            return cell
        } else {
            return MessageCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        
        if message.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorBtn.image = image
        imageSelected = true
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        if let txt = messageField.text where txt != "" {
            if let img = imageSelectorBtn.image where imageSelected == true {
                let urlString = "https://api.imageshack.com/v2/images"
                let url = NSURL(string: urlString)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "YZ79O1KF73a043232a253811ce4e2143f2526eb1".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    
                    multipartFormData.appendBodyPart(data: imgData, name: "filename", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    }) { encodingResult in
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: { response in
                                print(response.result.value)
                                if let info = response.result.value as? Dictionary<String, AnyObject> {
                                    if let dict = info["result"] as? Dictionary<String, AnyObject> {
                                        if let images = dict["images"]?[0] as? Dictionary<String, AnyObject> {
                                            if let imgLink = images["direct_link"] as? String {
                                                let imgDirectLink = "http://\(imgLink)"
                                                print("LINK: \(imgDirectLink)")
                                                self.postToFirebase(imgDirectLink)
                                            }
                                        }
                                    }
                                }
                            })
                        case .Failure(let error):
                            print(error)
                        }
                }
            } else {
                self.postToFirebase(nil)
            }
        }
    }
    
    func postToFirebase(imgUrl: String?) {
        var message: Dictionary<String, AnyObject> = [
            "textValue": "\(messageField.text!)",
            "likes": 0
        ]
        
        if imgUrl != nil {
            message["imageUrl"] = imgUrl!
        }
        
        print(message)
        let firebasePost = DataService.ds.REF_LOOP.childByAutoId()
        firebasePost.setValue(message)
        
        messageField.text = ""
        imageSelectorBtn.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
