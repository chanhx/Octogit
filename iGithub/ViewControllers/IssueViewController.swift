//
//  IssueViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class IssueViewController: BaseTableViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var viewModel: IssueViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHeader()
        
        if let headerView = self.tableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            self.tableView.tableHeaderView = headerView
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
        }
    }
    
    func configureHeader() {
        
        switch viewModel.issue.state! {
        case .Closed:
            statusLabel.text = Octicon.IssueClosed.rawValue
            statusLabel.textColor = UIColor(netHex: 0xBD2C00)
        case .Open:
            statusLabel.text = Octicon.IssueOpened.rawValue
            statusLabel.textColor = UIColor(netHex: 0x6CC644)
        }
        
        titleLabel.text = viewModel.issue.title
        
        userAvatar.setAvatarWithURL(viewModel.issue.user?.avatarURL)
        
        let attrInfo = NSMutableAttributedString(string: "\(viewModel.issue.user!) opened this issue \(viewModel.issue.createdAt!.naturalString)")
        attrInfo.addAttributes([
            NSForegroundColorAttributeName: UIColor(netHex: 0x555555),
            NSFontAttributeName: UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)
            ],
                              range: NSRange(location: 0, length: viewModel.issue.user!.login!.characters.count))
        
        infoLabel.attributedText = attrInfo
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
