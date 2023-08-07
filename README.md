# NEXCom

The NEXcom is  SIP-based app designed to communicate with NEXhome video intercom system.  You will be notified when visitors ring your intercom button, see who is at your doorway before opening the door, communicate with them via HD two-way voice and video with your mobile phone.


General description is available from [nexhome web site](https://www.nexhome.cn/).

### License

NEXCom is under a [GNU/GPLv3 license](https://www.gnu.org/licenses/gpl-3.0.en.html), for free (open source). Please make sure that you understand and agree with the terms of this license before using it (see LICENSE file for details).


# Building the application

## Building the app


If you don't have CocoaPods already, you can download and install it using :

```
sudo gem install cocoapods
```

**If you alreadly have Cocoapods, make sure that the version is higher than 1.7.5**.


- Install the app's dependencies with cocoapods first:

```
pod install
```

  It will download the dependency library from github so you don't have to build anything yourself.
  
- Then open `NEXCom.xcworkspace` file (**NOT NEXCom.xcodeproj**) with XCode to build and run the app.


# Limitations and known bugs

* Video capture will not work in simulator (not implemented in it).

