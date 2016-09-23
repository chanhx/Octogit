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
                .subscribe { _ in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }.addDisposableTo(disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHeader()
        
        if let headerView = self.tableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
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
        case .closed:
            statusLabel.text = Octicon.issueclosed.rawValue
            statusLabel.textColor = UIColor(netHex: 0xBD2C00)
        case .open:
            statusLabel.text = Octicon.issueopened.rawValue
            statusLabel.textColor = UIColor(netHex: 0x6CC644)
        }
        
        titleLabel.text = viewModel.issue.title
        
        userAvatar.setAvatarWithURL(viewModel.issue.user?.avatarURL)
        
        let attrInfo = NSMutableAttributedString(string: "\(viewModel.issue.user!) opened this issue \(viewModel.issue.createdAt!.naturalString)")
        attrInfo.addAttributes([
            NSForegroundColorAttributeName: UIColor(netHex: 0x555555),
            NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
            ],
                              range: NSRange(location: 0, length: viewModel.issue.user!.login!.characters.count))
        
        infoLabel.attributedText = attrInfo
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1//viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1//viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) == (0, 0) {
            return viewModel.contentHeight.value
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WebViewCell", for: indexPath) as! WebViewCell
        cell.webView.loadHTMLString(viewModel.contentHTML, baseURL: Bundle.main.resourceURL)
        cell.webView.navigationDelegate = viewModel
        
        return cell
    }
}
