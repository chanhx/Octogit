//
//  UserViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/28/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class UserViewController: UITableViewController {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var followersButton: CountButton!
    @IBOutlet weak var followingButton: CountButton!
    @IBOutlet weak var repositoriesButton: CountButton!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var viewModel: UserViewModel! {
        didSet {
            viewModel.user.asObservable()
                .subscribeNext { user in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        
                        self.avatarView.kf_setImageWithURL(user.avatarURL, placeholderImage: UIImage())
                        self.nameLabel.text = user.name ?? ""
                        self.followersButton.setTitle(user.followers, title: "Followers")
                        self.repositoriesButton.setTitle(user.publicRepos, title: "Repositories")
                        self.followingButton.setTitle(user.following, title: "Following")
                        
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
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.viewModel.title
        
        self.viewModel.fetchUser()
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return viewModel.numberOfSections
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.numberOfRowsInSection(section)
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
//        
//        guard viewModel.userLoaded else {
//            return cell
//        }
//        
//        switch indexPath.section {
//        case 0:
//            if viewModel.detailsRowsCount > 0 {
//                
//            }
//        case 1:
//            return detailsRowsCount > 0 ? 3 : 1
//        default:
//            return 1
//        }
//    }

}
