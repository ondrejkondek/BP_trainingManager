# Bachelor thesis - Training manager for iOS
##### Brno University of Technology
##### Faculty of Information Technology
##### Author: Ondrej Kondek
##### Supervisor: Ing. Martin Hrubý, Ph.D.
---
_This file contains information about implementation of the application, which is a subject of the bachelor thesis._
_Created by Ondrej Kondek, 11.5. 2021_
## Basic information about the project
---
The application Tajmer is meant to work as a tracking tool of user’s physical activities with emphasis on simple data input using extensions such as voice assistent Siri, widget and context menu. The user can create records of their activities, show their own statistics but they are also able to share data between other users of the application.

Project structure: 
* Implementation of application Tajmer (folder **TrainingManager**)
* Implementation of widget (folder **TrainingWidget**)
* Unit tests (folder **TrainingManagerTests**)
* Images used (folder **icons**)
* 3rd party libraries (folder **Pods**)

## Build requirements
---
The project is developed in **XCode 12.4** using **Swift 5**.
The simulator devices run **iOS 14.4**, so do physical devices on which the application was tested.
Last build was done on 11th of May, 2021 on MacbookPro 13'' 2018. During the whole development the newest versions of native libraries were used (CoreData, CloudKit, UIKit, ...). There were used 3rd party libraries, too: Charts and FSCalendar.

### How to build:
Firstly, open the file **TrainingManager.xcworkspace** in Xcode. Then you can directly press Cmd+R to build and run the application.

It is possible to run and test the application without signing to developer account. However, in some cases (mostly if you want to do some changes), Xcode might need you to sign in to your Apple developer account (you need to be a part of Brno University of Technology team). 

If any problems occur, make sure the settings **TrainingManager>Signing & Capibilities** are set as the following:

For target -> TrainingManager
* Appgroup - group.ondrejkondek.WidgetDemo
* Background Modes - Remote notifications 
* iCloud - All services, container: iCloud.TrainingManager

For target -> TrainingWidgetExtension
* Appgroup - group.ondrejkondek.WidgetDemo

*Tip: the exact same versions of the libraries are highly recommended (available in May 2021). Also make sure build settings are set to iOS 14.0 or higher.*

## Used technologies for development
---
Native libraries / frameworks:
* CoreData
* CloudKit
* UIKit
* Foundation
* WidgetKit
* CoreLocation

*All libraries were used in their most actual versions (May 2021).*

3rd party libraries:
* Charts - v.3.6.0
* FSCalendar - v.2.8.2

*3rd party libraries were downloaded and are located in folder Pods.*


## Dependency manager
--- 
**Pod** was used as a dependency manager. You can use Podfile (in home folder of the repository) to download needed dependencies. However, this is not recommended, since a newer version of the library might not be compatible.
All dependencies are located in folder Pods.

## Changes in library Charts
---
To achieve rounded borders of bars in barcharts, the library Charts was modified. In file BarChartRenderer.swift the method drawDataSet(context: CGContext, dataSet: IBarChartDataSet, index: Int) was changed based on a stackoverflow.com post. 
Credits to:
Answered by: keyv, Jun 21 '16 at 13:12
Edited by: Boris Y., Feb 2 '17 at 15:08
Source: https://stackoverflow.com/questions/37920237/rounded-bars-in-ios-charts

## Unit tests
---
Unit tests are located directly in the project (folder TrainingManagerTests) and may be launched in XCode.

## Contact
---
Ondrej Kondek
e-mail: xkonde04@stud.fit.vutbr.cz
