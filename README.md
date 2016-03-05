# knot-app-beta


download Knot App using the Download Zip button or forking to your local repo.

# Install
Once you have it added, select “Knot” on the left hand file explorer, select the target, and then go to ‘Build Settings’, then search for ‘Objective-C Bridging Header’ then change the value to the path of the file Bridging-Header.h on your local computer. 

Build the app in the simulator first, if you get errors related to Cocoa Pods then follow the instructions on these guides to fix the issues:
https://ungacy.atlassian.net/wiki/display/IOS/PCH+was+compiled+with+module+cache
http://stackoverflow.com/questions/7279141/how-can-i-safely-delete-in-my-library-developer-xcode-deriveddata-directory
http://stackoverflow.com/questions/27388957/pods-was-rejected-as-an-implicit-dependency-for-libpods-a-because-its-architec

# Using the Simulator

The simulator can’t use location data so go ‘AppDelegate.swift’, find the two lines commented:   
//calculate distance
//remember to switch this b4 release

To run on the simulator comment the next 10 lines, up until the line: self.locCurrent = CLLocation(latitude: 37.3853032084585, longitude: -122.153118002751)) and then uncomment self.locCurrent = CLLocation(latitude: 37.3853032084585, longitude: -122.153118002751).

To run locally and also before pushing to GitHub be sure to reverse this.
