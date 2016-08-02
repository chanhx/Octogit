//
//  IssueViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

class IssueViewController: BaseTableViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    let disposeBag = DisposeBag()
    var viewModel: IssueViewModel! {
        didSet {
            viewModel.contentHeight.asObservable()
                .skip(1)
                .distinctUntilChanged()
                .subscribeNext { _ in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }.addDisposableTo(disposeBag)
        }
    }
    
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
        return viewModel.numberOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section, indexPath.row) == (0, 0) {
            return viewModel.contentHeight.value
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WebViewCell", forIndexPath: indexPath) as! WebViewCell
        cell.webView.loadHTMLString(viewModel.contentHTML, baseURL: NSBundle.mainBundle().resourceURL)
        cell.webView.navigationDelegate = viewModel
        
        return cell
    }
}
