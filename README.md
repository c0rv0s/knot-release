# knot-app-beta


download Knot App using the Download Zip button or forking to your local repo.

This page details how to set up your global git username and upload your SSH keys to get access to forking, commits and other Git features.

# Install
Once you have it added, select “Knot” on the left hand file explorer, select the target, and then go to ‘Build Settings’, then search for ‘Objective-C Bridging Header’ then change the value to the path of the file Bridging-Header.h on your local computer. 

Build the app in the simulator first, if you get errors related to Cocoa Pods then follow the instructions on these guides to fix the issues:
https://ungacy.atlassian.net/wiki/display/IOS/PCH+was+compiled+with+module+cache
http://stackoverflow.com/questions/7279141/how-can-i-safely-delete-in-my-library-developer-xcode-deriveddata-directory
http://stackoverflow.com/questions/27388957/pods-was-rejected-as-an-implicit-dependency-for-libpods-a-because-its-architec



#other issues

If you experience error messages with "nil" and "NSURL" not being compatable, check the "Link Binaries With Libraries " and remove the Pods_Knot_framework file from the list

Contact at support@knotcomplex.com or engineering@knotcomplex.com
