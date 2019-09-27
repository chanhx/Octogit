//
//  MainTabBarController.swift
//  Octogit
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
        eventTVC.viewModel = EventTableViewModel(user: AccountManager.currentUser!, type: .received)
        
        for vc in self.viewControllers! {
            vc.view.backgroundColor = .white
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}
