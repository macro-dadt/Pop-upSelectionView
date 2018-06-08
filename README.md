# Pop-upSelectionView
[![Version](https://img.shields.io/cocoapods/v/NotificationBannerSwift.svg?style=flat)](http://cocoapods.org/pods/NotificationBannerSwift)
![](https://img.shields.io/badge/language-swift-blue.svg)
![](https://img.shields.io/badge/version-4.0-red.svg)

### About:
PupSelectionView simulate facebook emoji button with 2 options
+ pop-up on  a specific position
+ pop-up on a touched point
## Installation:
 • CocoaPods
LoginHelper is available through CocoaPods. To install it, simply add the following line to your Podfile:
```
pod "Pop-upSelectionView"
```
## Getting Started:
```
 var emojableButton:EmojiableView = EmojiableView()
```
 #### To handle events
 ```
 extension ViewController: EmojiableDelegate {

    func selectedOption(sender: EmojiableView, index: Int) {
        switch index {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        default:
            break
        }
    }
    
    func singleTap(sender: EmojiableView) {
    }
    
    func longTap(sender: EmojiableView) {
    }
    
    func canceledAction(sender: EmojiableView) {
        
    }
    
    func getSlectorView() -> SelectorView {
         return self.view as! SelectorView
    }
    
    func optionTap(index: Int) {
        
    }
    func getButtonArr() {
            contentView.delegate = self as EmojiableDelegate
            contentView.dataset = [
                EmojiableOption(image:"image1", name:"image1"),
                EmojiableOption(image:"image2", name:"image2"),
                EmojiableOption(image:"image3", name:"image3"),
                EmojiableOption(image:"image4", name:"image4"),
            ]
    }  
}
```
