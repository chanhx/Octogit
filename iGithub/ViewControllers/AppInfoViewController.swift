//
//  AppInfoViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 21/11/2016.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class AppInfoViewController: BaseTableViewController {
    
    @IBOutlet var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        let screenBounds = UIScreen.main.bounds
        let copyrightLabel = UILabel(frame: CGRect(x: 0, y: screenBounds.height - 90, width: screenBounds.width, height: 14))
        copyrightLabel.font = UIFont.systemFont(ofSize: 12)
        copyrightLabel.textColor = .lightGray
        copyrightLabel.textAlignment = .center
        view.addSubview(copyrightLabel)
        copyrightLabel.text = "Copyright © 2016, Hocheung Chan."
    }

}
