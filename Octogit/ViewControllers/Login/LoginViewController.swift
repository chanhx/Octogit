//
//  LoginViewController.swift
//  Octogit
//
//  Created by Chan Hocheung on 7/20/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var authorizeButton: UIButton! {
        didSet {
            authorizeButton.layer.borderColor = UIColor(netHex: 0x6cc644).cgColor
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
}
