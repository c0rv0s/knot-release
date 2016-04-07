# knot-app-beta


download Knot App using the Download Zip button or forking to your local repo.

# Install
Once you have it added, select “Knot” on the left hand file explorer, select the target, and then go to ‘Build Settings’, then search for ‘Objective-C Bridging Header’ then change the value to the path of the file Bridging-Header.h on your local computer. 

Build the app in the simulator first, if you get errors related to Cocoa Pods then follow the instructions on these guides to fix the issues:
https://ungacy.atlassian.net/wiki/display/IOS/PCH+was+compiled+with+module+cache
http://stackoverflow.com/questions/7279141/how-can-i-safely-delete-in-my-library-developer-xcode-deriveddata-directory
http://stackoverflow.com/questions/27388957/pods-was-rejected-as-an-implicit-dependency-for-libpods-a-because-its-architec

# Using the Simulator

The simulator can’t use location data so go ‘PhotoStreamViewController.swift’, find the two lines commented:   

self.locCurrent = CLLocation(latitude: 37.8051478737647, longitude: -122.426909426833)

self.appDelegate.locCurrent = CLLocation(latitude: 37.8051478737647, longitude: -122.426909426833)

to run on the simulator simply uncomment these lines, for running locally comment them again.

To run locally and also before pushing to GitHub be sure to reverse this.

#other issues

If you experience error messages with "nil" and "NSURL" not being compatable, check the "Link Binaries With Libraries " and remove the Pods_Knot_framework file from the list
