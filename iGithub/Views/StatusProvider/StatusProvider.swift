//
//  StatusProvider.swift
//
//  Created by MarioHahn on 23/08/16.
//

import Foundation
import UIKit


public enum StatusProviderType {
    
    struct Constants {
        static let loadingTag   = 7023
        static let errorTag     = 7024
        static let emptyTag     = 7025
        static let noneTag      = 7026
    }
    
    case loading
    case error(error: NSError?, retry: (()->Void)?)
    case empty
    case none
    
    static func allViewTags() -> [Int] {
        return [ Constants.loadingTag,Constants.errorTag,Constants.emptyTag,Constants.noneTag]
    }
    
    func viewTag() -> Int{
        switch self {
        case .loading:     return  Constants.loadingTag
        case .error(_, _): return  Constants.errorTag
        case .empty:       return  Constants.emptyTag
        case .none:        return  Constants.noneTag
        }
    }
}

public protocol StatusOnViewProvider {
    var onView: UIView { get }
}

public protocol StatusProvider: StatusOnViewProvider {
    
    var loadingView: UIView?                    { get }
    var errorView: ErrorStatusDisplaying?       { get }
    var emptyView: UIView?                      { get }
    
    func show(statusType type: StatusProviderType)
    func hide(statusType type: StatusProviderType)
}

extension StatusOnViewProvider where Self: UIViewController {
    
    public var onView: UIView {
        return view
    }
}

extension StatusOnViewProvider where Self: UIView {
    
    public var onView: UIView {
        return self
    }
}

public protocol ErrorStatusDisplaying: class {
    
    var error: NSError?             { set get }
    var retry: (()->Void)?          { set get }
}

extension StatusProvider {
    
    
    public var loadingView: UIView? {
        get {
            #if os(tvOS)
                return LoadingStatusView(loadingStyle: .activity)
            #elseif os(iOS)
                return LoadingStatusView(loadingStyle: .labelWithActivity)
            #else
                return nil
            #endif
        }
    }
    
    public var errorView: ErrorStatusDisplaying? {
        get { return ErrorStatusView() }
    }
    
    public var emptyView: UIView? {
        get { return nil }
    }
    
    public func hide(statusType type: StatusProviderType) {
        remove(viewTag: type.viewTag())
    }
    
    func remove(viewTag tag: Int){
        onView.viewWithTag(tag)?.removeFromSuperview()
    }
    
    public func show(statusType type: StatusProviderType) {
        
        StatusProviderType.allViewTags().forEach({ remove(viewTag: $0) })
        
        var statusView: UIView? = nil
        
        switch type {
        case let .error(error, retry):
            
            statusView = errorView as? UIView
            (statusView as? ErrorStatusDisplaying)?.error = error
            (statusView as? ErrorStatusDisplaying)?.retry = retry
            
        case .loading:
            statusView = loadingView
        case .empty:
            statusView = emptyView
            
        case .none: break
        }
        
        statusView?.tag = type.viewTag()
        addViewAndCenterConstraints(statusView)
    }
    
    fileprivate func addViewAndCenterConstraints(_ view: UIView?) {
        
        guard let view = view else { return }
        
        onView.insertSubview(view, at: 0)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: onView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: onView.centerYAnchor),
            view.leadingAnchor.constraint(greaterThanOrEqualTo: onView.leadingAnchor),
            view.trailingAnchor.constraint(lessThanOrEqualTo: onView.trailingAnchor),
            view.topAnchor.constraint(greaterThanOrEqualTo: onView.topAnchor),
            view.bottomAnchor.constraint(lessThanOrEqualTo: onView.bottomAnchor)
            ])
    }
}
