//
//  ExplorationViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class ExplorationViewController: BaseTableViewController, UISearchControllerDelegate {
    
    let viewModel = ExplorationViewModel()
    let headerView = SegmentHeaderView()
    
    var searchController: UISearchController!
    var searchViewController = SearchViewController()
    
    lazy var pickerView: OptionPickerView = OptionPickerView(delegate:self, optionsCount: 2)
    lazy var background: UIView! = {
        let background = UIView(frame: self.navigationController!.view.window!.bounds)
        background.frame = self.view.bounds
        background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removePickerView)))
        background.addGestureRecognizer(UIPanGestureRecognizer(target: nil, action: nil))
        return background
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(netHex: 0xFAFAFA)
        
        headerView.delegate = self
        headerView.title = .Repositories
        headerView.titleLabel.delegate = self
        updateTitle()
        
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
}

extension ExplorationViewController: SegmentHeaderViewDelegate {
    
    func headerView(view: SegmentHeaderView, didSelectSegmentTitle title: TrendingType) {
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
}

extension ExplorationViewController: TTTAttributedLabelDelegate {
    
    func updateTitle() {
        let time = viewModel.pickerVM.timeOptions[pickerView.selectedRow[0]].desc
        headerView.titleLabel.text = "Trending for \(time) in \(viewModel.language)"
        headerView.titleLabel.addLink(NSURL(string: "Time")!, toText: time)
        
        let language = viewModel.language.stringByReplacingOccurrencesOfString("+", withString: "\\+")
        headerView.titleLabel.addLink(NSURL(string: "Language")!, toText: language)
    }
    
    // MARK: TTTAttributedLabelDelegate
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        switch url.absoluteString {
        case "Time":
            pickerView.index = 0
        default:
            pickerView.index = 1
        }
        
        showPickerView()
    }
    
    // MARK: picker view
    
    func showPickerView() {
        navigationController?.view.window?.addSubview(background)
        
        var pickerFrame = view.frame
        pickerFrame.origin.y = view.frame.height
        pickerFrame.size.height = pickerView.intrinsicContentSize().height
        pickerView.frame = pickerFrame
        
        UIApplication.sharedApplication().windows.last?.addSubview(pickerView)
        
        UIView.animateWithDuration(0.2) {
            pickerFrame.origin.y -= pickerFrame.size.height
            self.pickerView.frame = pickerFrame
        }
    }
    
    func removePickerView() {
        background.removeFromSuperview()
        
        UIView.animateWithDuration(0.2, animations: {
            var frame = self.pickerView.frame
            frame.origin.y += self.pickerView.frame.height
            self.pickerView.frame = frame
        }) { _ in
            self.pickerView.clearRecord()
            self.pickerView.removeFromSuperview()
        }
    }
}

extension ExplorationViewController: OptionPickerViewDelegate {
    
    func doneButtonClicked() {
        removePickerView()
        
        if let row0 = pickerView.tmpSelectedRow[0] {
            pickerView.selectedRow[0] = row0
            viewModel.since = viewModel.pickerVM.timeOptions[row0].time
        }
        if let row1 = pickerView.tmpSelectedRow[1] {
            pickerView.selectedRow[1] = row1
            viewModel.language = languages[row1]
        }
        viewModel.updateOptions()
        updateTitle()
        pickerView.clearRecord()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerView.index == 0 ? 3 : languages.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerView.index == 0 ? viewModel.timeOptions[row] : languages[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickerView.tmpSelectedRow[self.pickerView.index] = row
    }
}
