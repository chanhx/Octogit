//
//  ExplorationViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class ExplorationViewController: BaseTableViewController, SegmentHeaderViewDelegate, TTTAttributedLabelDelegate,
                                 UISearchControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let viewModel = ExplorationViewModel()
    let headerView = SegmentHeaderView()
    
    var searchController: UISearchController!
    var searchViewController = SearchViewController()
    
    lazy var pickerView: OptionPickerView = OptionPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(netHex: 0xFAFAFA)
        
        headerView.delegate = self
        headerView.title = .Repositories
        headerView.titleLabel.delegate = self
        headerView.pickerView.dataSource = self
        headerView.pickerView.delegate = self
        
        searchController = UISearchController(searchResultsController: searchViewController)
        
        searchController.searchResultsUpdater = searchViewController
        searchController.searchBar.delegate = searchViewController
        searchController.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        
        navigationItem.titleView = searchController.searchBar
        
        definesPresentationContext = true
    }
    
    // MARK: UISearchControllerDelegate
    
//    func didDismissSearchController(searchController: UISearchController) {
//        searchViewController clear search results
//    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    // MARK: header
    
    func headerView(view: SegmentHeaderView, didSelectSegmentTitle title: SegmentTitle) {
        switch title {
        case .Repositories:
            bindToRepoTVM()
        case .Users:
            bindToUserTVM()
        }
        
        viewModel.type = title
    }
    
    func bindToRepoTVM() {
        viewModel.repoTVM.repositories.asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier("TrendingRepoCell", cellType: TrendingRepoCell.self)) {
                row, repo, cell in
                cell.configureCell(repo.name, description: repo.description, meta: repo.meta)
            }
            .addDisposableTo(viewModel.repoTVM.disposeBag)
    }
    
    func bindToUserTVM() {
        viewModel.userTVM.users.asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier("UserCell", cellType: UserCell.self)) {
                row, user, cell in
                cell.entity = user
            }
            .addDisposableTo(viewModel.userTVM.disposeBag)
    }
    
    // MARK: TTTAttributedLabelDelegate
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        
        let background = UIView(frame: navigationController!.view.window!.bounds)
        background.frame = view.bounds
        background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removePickerView(_:))))
        background.addGestureRecognizer(UIPanGestureRecognizer(target: nil, action: nil))
        navigationController?.view.window?.addSubview(background)
        
        pickerView.pickerView.dataSource = self
        pickerView.pickerView.delegate = self
        let viewFrame = view.frame
        var pickerFrame = viewFrame
        pickerFrame.size.height = pickerView.toolBar.intrinsicContentSize().height + pickerView.pickerView.intrinsicContentSize().height
        pickerFrame.origin.y = viewFrame.height
        pickerView.frame = pickerFrame
        navigationController?.view.window?.addSubview(pickerView)
        
        UIView.animateWithDuration(0.2) {
            pickerFrame.origin.y = viewFrame.height - pickerFrame.size.height
            self.pickerView.frame = pickerFrame
        }
    }

    // MARK: picker view
    
    func removePickerView(recognizer: UIGestureRecognizer) {
        recognizer.view!.removeFromSuperview()
        
        UIView.animateWithDuration(0.2, animations: {
            var frame = self.pickerView.frame
            frame.origin.y += self.pickerView.frame.height
            self.pickerView.frame = frame
        }) { _ in
            self.pickerView.removeFromSuperview()
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "123"
    }
}
