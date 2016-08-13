//
//  MainTabBarController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        let eventTVC = (viewControllers![0]  as! UINavigationController).topViewController as! EventTableViewController
        eventTVC.viewModel = EventTableViewModel(user: AccountManager.shareManager.currentUser!, type: .Received)
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
    }
}
