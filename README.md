# iOS Virtual File System #
By Taiwon Chung and Cyrus Forbes

## Application Overview ##
With the limited extensibility to iOS’s platform itself, our solution to preventing the user from sending files to unauthorized apps was to create a file system app that crashes if it detects that the user is trying to send a file to an unauthorized app, preventing the file from being sent to the unauthorized app’s Documents/Inbox/ directory. Although the solution of crashing the app is not elegant, iOS does not offer any other way to stop a file from being sent. There are some delegate functions that the developer can implement to do some configuration before the actual sending of the file by the document interaction controller, but they cannot be used to change the chain of execution, such as gracefully stopping the execution after a few checks.
######
When the user taps an application in the tray, the file begins to transfer to the tapped application’s Documents/Inbox/ directory. The particular delegate function that we implemented in this project to prevent the sending of the file is called “willBeginSending- ToApplication”. This delegate function is called before the file has actually begun to be sent and also gets the tapped application’s information as one of its arguments, so we used this function to check if the tapped app is authorized, and if it is not, to throw an error, which consequently crashes the app because there is no exception catching mechanism in Swift, in order to prevent the file from being sent.

## Node.js / MongoDB Server ##
The Node.js server both hosts an HTTP API for manipulating and viewing the MongoDB database and hosts the MongoDB database as well. The iOS file system app makes requests to the Node.js server in order to retrieve a list of approved apps, while the web interface makes requests to the server not only to retrieve a list of approved apps, but also to add/delete apps.
######
The HTTP API follows REST protocol:
	GET /items Returns a list of approved apps in json.
	POST /items Adds a new approved app to the list using the POST data.
	PUT /items/:id Updates the approved app with :id using the PUT data.
	DELETE /items/:id Removes the approved app with :id from the list.
## Application Interface ##
When the file system application launches on the device, it will make API calls to the web server and get all the necessary information about authorized apps. It will cache that info in memory, and then use file extension information to layout all the files in Documents/ directory using UITableView.
######
When the user taps on a file and taps on Open, it will open up a document interaction controller tray. User can also tap on New Dir, which will open another view to make a new directory. It does simple error checking, such as empty name check and same name check. The application also has refresh button rather than a push system for policy management, since it does not persistently store the policy.
## Code Structure ##
### ViewController.swift ### 
This contains implementation for the main view controller for file system navigation interface. When user navigates to another directory, this generates a new instance of itself with a new currentDirectory set and pushes it to navigation stack

### AppDelegate.swift ###
This contains implementation for this app's delegate. We added downloadAuthorizedApps function so that any ViewController instance can access this app delegate to update the policy and its own view according to updated policy.

### MkDirController.swift ###
This contains implementation for view controller used for making a new directory.

## Related Work ##
There is a lot of related work in the Android field, but not much in the iOS field. We believe that Android has been more heavily focused since it’s API is more open, which allows more control over files. A paper was written in 2012 about securing enterprise files on Android (http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=6341406). This paper discusses restricting file flows on the user’s device, which is a better solution than ours in many ways, but unfortunately is not possible on iOS.
## Next Steps ##
Currently, the list of approved apps only updates when the user opens the app or when the user presses the refresh button. We want to implement a push system, so that when there is a change in the Node.js server, it is immediately reflected in the iOS app. Although this is possible to do in many different ways, we are still discussing which method would provide the least overhead. We would rather not have the app poll for changes or even use websockets as that would drain the battery life of the phone very quickly. We are looking into apple push notifications to see if there is a way to use them to update the list while not displaying a notification to the user.
The web interface does not have any security at the moment since it’s being used for demo purposes. We would like to add a login/token based authentication to each HTTP request so that only approved people can change the list of approved apps. We would also like to make it so that each “company” has their own list of approved apps so that this app could be used by more than just one company.
Also, the file system application itself is not yet complete because the user has no way of saving files into it. Right now, all the files in the app is downloaded from the web when it gets installed. So for the future, saving file capability should be added. Along with capability to save files into the application, capability to modify existing files in the file system and saving them back should be also added. For example, the user should be able to open a doc file in word processing application, edit the file, and save it back to the file system. This may require further research in file-descriptor-like functionalities in iOS.