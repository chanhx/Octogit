<p align=center><img src="http://twicketapp.github.io/Images/twicket_banner.jpg" height="300px"/></p>

# TwicketSegmentedControl
![](https://img.shields.io/badge/Swift-3.0-blue.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Custom UISegmentedControl replacement for iOS, written in Swift, used in the Twicket app.

###Features:

- Drag gesture
- Movement animation
- IB compatible
- Customizable colors


###How to use it:
You can either create it using Interface Builder, or by code. 

Whenever the segmented control is instantiated, you'll have to tell it which are going to be the segments it will have:

```swift
	let titles = ["First", "Second", "Third"]
	segmentedControl.setSegmentItems(titles)

```
Every time you use this function, the control is redrawn.

If you want to manually move to an index:

```swift
	segmentedControl.move(to: 2)
```
Keep in mind that the first segment index is `0`

To listen to changes on the selected index you have a delegate with the following interface:

```swift
    func didSelect(_ segmentIndex: Int)
```

One last thing to mention, even if you set a different outer frame, its contentView height will always be `40`.


### Customization:

You can customize the segmented control through the following properties:

__defaultTextColor__: UIColor - Text color for unselected segments

__highlightTextColor__: UIColor - Text color for selected segment

__segmentsBackgroundColor__: UIColor - Background color for unselected segments

__highlightTextColor__: UIColor - Background color for selected segment

###Installation:
####• CocoaPods

```
use_frameworks!

pod 'TwicketSegmentedControl'
```
####• Carthage

```
github "poolqf/FillableLoaders"
```
####• Manually

To manually add `FillableLoaders` to your project you just need to copy the `Source` folder files.
