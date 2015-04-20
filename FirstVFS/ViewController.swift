//
//  ViewController.swift
//  FirstVFS
//
//  Created by Taiwon Chung on 1/28/15.
//  Copyright (c) 2015 Northwestern University. All rights reserved.
//

import UIKit

//TO-

class ViewController: UIViewController, UIDocumentInteractionControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var directoryTableView: UITableView!
    @IBOutlet weak var openButton: UIButton!
    var fileList:NSArray?
    var appdel = UIApplication.sharedApplication().delegate as AppDelegate
    var tableDS = [[String]]()
    var selectedFile:NSIndexPath?
    var docController:UIDocumentInteractionController?
    var currentDirectory:String?
    
    override func viewDidAppear(animated: Bool) {
        // every time this view appears, reload data for table view
        super.viewDidAppear(animated)
        fileList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(currentDirectory!, error: nil)
        self.reloadTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        savePdf()
        self.navigationItem.title = "\(currentDirectory!.lastPathComponent)/"
    }
    
    func reloadTableView() {
        fileList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(currentDirectory!, error: nil)
        if fileList == nil || self.appdel.authorizedApps == nil {
            return
        } else {
            tableDS = [[String]]()
            tableDS.append([String]())
            for i in 1...self.appdel.authorizedApps!.count {
                tableDS.append([String]())
            }
            for file in fileList as [String] {
                let path = currentDirectory!.stringByAppendingPathComponent(file)
                let contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error: nil)
                if contents == nil {
                    for i in 0...self.appdel.authorizedApps!.count-1 {
                        let fileExt = ".\(path.pathExtension)"
                        let exts = self.appdel.authorizedApps!.objectAtIndex(i)["exts"] as [String]
                        let fExts = exts.filter({$0==fileExt})
                        if !fExts.isEmpty {
                            tableDS[i+1].append(file)
                        }
                    }
                } else {
                    tableDS[0].append(file)
                }
            }
            println(tableDS)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.directoryTableView.reloadData()
            })
        }
    }
    
    @IBAction func openDoc() {
        // TO-DO: prevent crashing when open button is tapped when no file is selected
        self.openFile()
    }
    
    @IBAction func refresh(sender: AnyObject) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.appdel.downloadAuthorizedApps(self)
    }
    
    func savePdf() -> Void {
        // IMPORTANT: This function downloads two pdf files and saves it persistently to Documents directory
        // It only downloads them if they don't already exist in the directory
        // This won't be necessary if saving capability is implemented
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docPath: AnyObject = paths.objectAtIndex(0)
        var filePath: String = docPath.stringByAppendingPathComponent("formw4.pdf")
        var url:NSURL
        var dataObj:NSData
        if (~NSFileManager.defaultManager().fileExistsAtPath(filePath)) {
            url = NSURL(string: "http://www.irs.gov/pub/irs-pdf/fw4.pdf")!
            dataObj = NSData(contentsOfURL: url)!
            NSFileManager.defaultManager().createFileAtPath(filePath, contents: dataObj, attributes: nil)
            //dataObj?.writeToFile(filePath!, atomically: true)
            //println(filePath)
            //println(paths)
            //println(NSFileManager.defaultManager().fileExistsAtPath(filePath))
        }
        filePath = docPath.stringByAppendingPathComponent("bitcoin.pdf")
        if (~NSFileManager.defaultManager().fileExistsAtPath(filePath)) {
            url = NSURL(string: "https://bitcoin.org/bitcoin.pdf")!
            dataObj = NSData(contentsOfURL: url)!
            NSFileManager.defaultManager().createFileAtPath(filePath, contents: dataObj, attributes: nil)
        }
    }
    
    func openFile() -> Void {
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docPath: AnyObject = paths.objectAtIndex(0)
        let filePath: String = docPath.stringByAppendingPathComponent(tableDS[selectedFile!.section][selectedFile!.row] as String)
        let url = NSURL(fileURLWithPath: filePath)
        self.docController = UIDocumentInteractionController(URL: url!)
        self.docController?.delegate = self
        let res = self.docController?.presentOpenInMenuFromRect(self.openButton.frame, inView: self.view, animated: true)
        println(res)
    }
    
    func documentInteractionControllerWillPresentOpenInMenu(controller: UIDocumentInteractionController) {
    }
    
    func documentInteractionController(controller: UIDocumentInteractionController, willBeginSendingToApplication application: String) {
        var flag = 0
        let path = self.currentDirectory!.stringByAppendingPathComponent(self.tableDS[selectedFile!.section][selectedFile!.row])
        let ext = ".\(path.pathExtension)"
        println("willBeginSendingToApplication")
        println(application)
        
        for i in 0...self.appdel.authorizedApps!.count-1 {
            if (application==self.appdel.authorizedApps!.objectAtIndex(i)["id"] as String) {
                let exts = self.appdel.authorizedApps!.objectAtIndex(i)["exts"] as [String]
                let filtered = exts.filter({$0==ext})
                if !filtered.isEmpty {
                    flag = 1
                }
                break;
            }
        }
        if (flag == 0) {
            let foo = NSException(name: "unauthApp", reason: "tried to open with unauthorized app", userInfo:["appName": application])
            foo.raise()
        }
    }
    func documentInteractionController(controller: UIDocumentInteractionController, didEndSendingToApplication application: String) {
        println("didEndSendingToApplication")
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.appdel.authorizedApps == nil {
            return 0
        } else {
            return self.appdel.authorizedApps!.count+1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tableDS.count == 0 {
            return 0
        } else {
            return self.tableDS[section].count
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mkdirSegue" {
            if let destinationController = segue.destinationViewController as? MkdirController {
                destinationController.currentDir = self.currentDirectory
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.appdel.appImgs == nil {
            return UIImageView()
        } else {
            //println(section)
            // IMPORTANT: hard-coded sizes assuming this app is running in iPhone6
            // update this code to improve UI for different devices
            if section == 0 {
                let headerView = UIView()
                let imgView = UIImageView(frame: CGRectMake(20, 20, 30, 30))
                imgView.image = UIImage(named: "folder")
                imgView.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin
                headerView.addSubview(imgView)
                return headerView
            } else {
                let headerView = UIView()
                let imgView = UIImageView(frame: CGRectMake(20, 20, 30, 30))
                imgView.image = self.appdel.appImgs![section-1]
                imgView.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin
                headerView.addSubview(imgView)
                return headerView
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("dirCell", forIndexPath: indexPath) as UITableViewCell
            let title = cell.contentView.viewWithTag(1) as UILabel
            title.text = "\(tableDS[indexPath.section][indexPath.row])/"
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("fileCell", forIndexPath: indexPath) as UITableViewCell
            let title = cell.contentView.viewWithTag(1) as UILabel
            title.text = tableDS[indexPath.section][indexPath.row]
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let reuseId = self.directoryTableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
        let path = currentDirectory!.stringByAppendingPathComponent(tableDS[indexPath.section][indexPath.row] as String)
        if (reuseId == "fileCell") {
            //println("selected a file")
            self.selectedFile = indexPath
        } else {
            //println("selected a directory")
            let vc = storyboard!.instantiateViewControllerWithIdentifier("DirectoryViewController") as ViewController
            let nc = self.navigationController
            vc.currentDirectory = path
            nc?.pushViewController(vc, animated: true)
            //vc.reloadTableView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

