Jog Journal
==========

An iOS demo app for recording jog data. I coded this as part of my screening process with [Toptal](http://www.toptal.com/resume/jamie-mcdaniel).

The app demostrates my skill-set with:

* iOS 7.0 SDK
* UIKit and Auto layout
* Core Data
* Core Location
* Parse iOS SDK
* Writing clean code

##Core Data Object Graph
User data is persisted locally using Core Data. Basically a user has jogs and jogs have locations.
![](https://raw.github.com/jamiemcd/JogJournal/master/Screenshots/CoreData.png)

##Parse
User data is persisted to the cloud via Parse. Unlike the Core Data object graph, there are just two Parse classes: User and 
Jog. Location data is stored as a JSON file that is associated with a Jog. This results in less API calls to Parse and is fine
because we do not need to do any querying on individual location data (i.e. we are only concerned about the entire collection 
of location data that makes up a jog).

Example location data JSON file:

    [{"longitude":-122.03038642,"latitude":37.33182081,"timestamp":"2013-12-31T21:59:34.729Z"},
    {"longitude":-122.03043332,"latitude":37.33181965,"timestamp":"2013-12-31T21:59:35.737Z"},
    {"longitude":-122.03048154,"latitude":37.33181512,"timestamp":"2013-12-31T21:59:36.744Z"},
    {"longitude":-122.03071596,"latitude":37.33150351,"timestamp":"2013-12-31T21:59:47.780Z"}]

##iOS Simulator
Once logged in, the user can start a new jog. The iOS simulator has some location profiles to test with, such as "City Run".

![](https://raw.github.com/jamiemcd/JogJournal/master/Screenshots/CityRun.png)

##Screenshots

![](https://raw.github.com/jamiemcd/JogJournal/master/Screenshots/JogJournal01.png)

![](https://raw.github.com/jamiemcd/JogJournal/master/Screenshots/JogJournal02.png)

![](https://raw.github.com/jamiemcd/JogJournal/master/Screenshots/JogJournal03.png)