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
        copyrightLabel.text = "Copyright © 2016-2017, Hocheung Chan."
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if indexPath.row == 1 {
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/us/app/octogit/id1181732351?mt=8")!)
        } else if indexPath.row == 3 {
            let repoVC = RepositoryViewController.instantiateFromStoryboard()
            repoVC.viewModel = RepositoryViewModel(repo: "chanhx/Octogit")
            self.navigationController?.pushViewController(repoVC, animated: true)
        }
    }
}
