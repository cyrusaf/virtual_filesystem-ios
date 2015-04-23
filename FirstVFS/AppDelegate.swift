//
//  AppDelegate.swift
//  FirstVFS
//
//  Created by Taiwon Chung on 1/28/15.
//  Copyright (c) 2015 Northwestern University. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // policy cache
    // TO-DO: implement a data model (a Swift class) for storing app info rather than accessing in dictionary
    // having this will improve readability of the code
    var authorizedApps:NSArray?
    var appImgs:[UIImage]?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        // Override point for customization after application launch.
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docPath: AnyObject = paths.objectAtIndex(0)
        let navController = self.window?.rootViewController as UINavigationController
        let vc = navController.topViewController as ViewController
        vc.currentDirectory = docPath as? String
        self.downloadAuthorizedApps(vc)
        //vc.reloadTableView()
        return true
    }
    
    func downloadAuthorizedApps(vc:ViewController) {
        // IMPORTANT: this url does not work unless there is a server running at that IP
        // change this url to url where the server is running
        let urlString = "http://10.101.22.115:3001/items"
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        var queue:NSOperationQueue = NSOperationQueue()
        // get authorized apps
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response:NSURLResponse!, responseData:NSData!, error:NSError!) -> Void in
            //println(responseData)
            if (error != nil) {
                println(error.description)
            } else {
                var arr = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSArray
                var imgarr = [UIImage]()
                self.authorizedApps = arr
                //println(vc.authorizedApps)
                // get images for app icons
                for i in 0...self.authorizedApps!.count-1 {
                    println(self.authorizedApps!.objectAtIndex(i)["img"] as String)
                    let imgurl = NSURL(string: self.authorizedApps!.objectAtIndex(i)["img"] as String)
                    var imgresponse:AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
                    let imgrequest = NSURLRequest(URL: imgurl!)
                    var imgdata = NSURLConnection.sendSynchronousRequest(imgrequest, returningResponse: imgresponse, error: nil)
                    let img = UIImage(data: imgdata!)
                    imgarr.append(img!)
                }
                self.appImgs = imgarr
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                vc.reloadTableView()
            }
        }

    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

