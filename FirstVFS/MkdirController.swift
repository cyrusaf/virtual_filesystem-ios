//
//  MkdirController.swift
//  FirstVFS
//
//  Created by Taiwon Chung on 3/2/15.
//  Copyright (c) 2015 Northwestern University. All rights reserved.
//

import UIKit

class MkdirController: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    var currentDir: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //println(currentDir)
        nameField.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        alertView.dismissWithClickedButtonIndex(buttonIndex, animated: true)
    }
    
    @IBAction func cancelMkdir() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    @IBAction func createDirectory() {
        let name = nameField.text
        if (name == "") {
            let alertView = UIAlertView(title: "No Name", message: "You have to enter a name for the new directory.", delegate: self, cancelButtonTitle: "Ok")
            alertView.show()
        } else if (NSFileManager.defaultManager().fileExistsAtPath(self.currentDir!.stringByAppendingPathComponent(name))) {
            let alertView = UIAlertView(title: "Already Exists", message: "There is already a directory with same name. Please enter a different name", delegate: self, cancelButtonTitle: "Ok")
            alertView.show()
        } else {
            //println(name)
            NSFileManager.defaultManager().createDirectoryAtPath(self.currentDir!.stringByAppendingPathComponent(name), withIntermediateDirectories: true, attributes: nil, error: nil)
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
    }
}
