# StatusProvider

![Screenshot](https://github.com/mariohahn/StatusProvider/blob/master/Github%20Screenshots/StatusProvider.png?raw=true)

Protocol to handle initial Loadings, Empty Views and Error Handling in a ViewController &amp; views

## CocoaPods Podfile

```ruby
pod 'StatusProvider'
```

## Functions 

* Loading
* EmptyView 
* Error Handling 


```swift
    func show(statusType type: StatusProviderType)
    func hide(statusType type: StatusProviderType)
    
    public enum StatusProviderType {
        case Loading
        case Error(error: NSError?, retry: (()->Void)?)
        case Empty(action: (()->Void)?)
        case None
    }
```

## How to use? 
```swift
extension YourViewController: StatusProvider { }

class YourViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDataAsynchron()
    }
    
    func loadDataAsynchron() {
        
        show(statusType: .Loading)
        
        dispatch_after(dispatch_time( DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))),dispatch_get_main_queue()){
            
            let error = NSError(domain: "my.domain", code: 405, userInfo: [NSLocalizedDescriptionKey : "Oh... fu**"])
            
            self.show(statusType: StatusProviderType.Error(error: error, retry: {
                self.loadDataAsynchron()
            }))
        }
    }
}
```

## Custom Status Views 

```swift
class MyCustomEmptyView: UIView { }
class MyCustomLoadingView: UIView { }
class MyCustomErrorView: UIView, ErrorStatusDisplaying {

    var error: NSError?{
        didSet{ /*do your Sh** */}
    }
    
    var retry: (() -> Void)?{
        didSet{ /*do your Sh** */}
    }
}

extension YourViewController: StatusProvider {

    var emptyView: UIView?{
        return MyCustomEmtyView()
    }
    
    var loadingView: UIView?{
        return MyCustomLoadingView()
    }
    
    var errorView: ErrorStatusDisplaying? {
        return MyCustomErrorView()
    }
}

```

