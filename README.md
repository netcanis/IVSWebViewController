# IVSWebViewController

[![CI Status](http://img.shields.io/travis/netcanis/IVSWebViewController.svg?style=flat)](https://travis-ci.org/netcanis/IVSWebViewController)
[![Version](https://img.shields.io/cocoapods/v/IVSWebViewController.svg?style=flat)](http://cocoapods.org/pods/IVSWebViewController)
[![License](https://img.shields.io/cocoapods/l/IVSWebViewController.svg?style=flat)](http://cocoapods.org/pods/IVSWebViewController)
[![Platform](https://img.shields.io/cocoapods/p/IVSWebViewController.svg?style=flat)](http://cocoapods.org/pods/IVSWebViewController)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```objc
IVSWebViewController *vc = [[IVSWebViewController alloc] init];
UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
[vc loadURLString:@"https://www.google.com"];
[self presentViewController:navi animated:YES completion:nil];
```


## Requirements
- Base SDK: iOS 10
- Deployment Target: iOS 9.0 or greater
- Xcode 8.x

## Installation

IVSWebViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "IVSWebViewController"
```

## Author

netcanis, netcanis@gmail.com

## License

IVSWebViewController is available under the MIT license. See the LICENSE file for more info.
