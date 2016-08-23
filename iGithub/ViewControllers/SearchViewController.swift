//
//  SearchViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/15/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

class SearchViewController: BaseTableViewController {
    
    let viewModel = SearchViewModel()
    let headerView = SegmentHeaderView()
    
    lazy var repoOptionsPickerView: OptionPickerView = OptionPickerView(delegate: self, optionsCount: 2)
    lazy var userOptionPickerView: OptionPickerView = OptionPickerView(delegate: self, optionsCount: 1)
    lazy var background: UIView! = {
        let background = UIView(frame: UIApplication.sharedApplication().windows.last!.bounds)
        background.frame = self.view.bounds
        background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removePickerView)))
        background.addGestureRecognizer(UIPanGestureRecognizer(target: nil, action: nil))
        return background
    }()
    
    init () {
        super.init(style: .Grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .OnDrag
        tableView.backgroundColor = UIColor(netHex: 0xFAFAFA)
        tableView.registerClass(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "UserCell")
        
        headerView.delegate = self
        headerView.title = .Repositories
        headerView.titleLabel.delegate = self
        updateTitle()
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let query = searchController.searchBar.text
        
        if query == nil || query?.characters.count <= 0 {
            self.view.hidden = false
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if let query = searchBar.text where query.characters.count > 0 {
            viewModel.search(query)
        }
    }
}

extension SearchViewController: SegmentHeaderViewDelegate {
    
    func headerView(view: SegmentHeaderView, didSelectSegmentTitle title: TrendingType) {
        switch title {
        case .Repositories:
            bindToRepoTVM()
            viewModel.option = viewModel.options[0]
        case .Users:
            bindToUserTVM()
            viewModel.option = viewModel.options[1]
        }
        
        updateTitle()
    }
    
    func bindToRepoTVM() {
        viewModel.repoTVM.repositories.asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier("RepositoryCell", cellType: RepositoryCell.self)) {
                row, repo, cell in
                cell.entity = repo
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

extension SearchViewController: TTTAttributedLabelDelegate {
    
    func updateTitle() {
        let sortDescription = viewModel.titleVM.sortDescription(viewModel.option)
        switch viewModel.option {
        case .Repositories(_, let language):
            headerView.titleLabel.text = "Sort: \(sortDescription) | Language: \(language)"
            headerView.titleLabel.addLink(NSURL(string: "ReposSort")!, toText: sortDescription)
            headerView.titleLabel.addLink(NSURL(string: "Language")!,
                                          toText: language.stringByReplacingOccurrencesOfString("+", withString: "\\+"))
        case .Users(_):
            headerView.titleLabel.text = "Sort: \(sortDescription)"
            headerView.titleLabel.addLink(NSURL(string: "UsersSort")!, toText: sortDescription)
        }
    }
    
    // MARK: TTTAttributedLabelDelegate
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        switch url.absoluteString {
        case "ReposSort":
            repoOptionsPickerView.index = 0
            showPickerView(repoOptionsPickerView)
        case "Language":
            repoOptionsPickerView.index = 1
            showPickerView(repoOptionsPickerView)
        default:
            userOptionPickerView.index = 0
            showPickerView(userOptionPickerView)
        }
    }
    
    // MARK: picker view
    
    func showPickerView(pickerView: OptionPickerView) {
        UIApplication.sharedApplication().windows.last?.addSubview(background)
        
        var pickerFrame = view.frame
        pickerFrame.origin.y = view.frame.height
        pickerFrame.size.height = pickerView.intrinsicContentSize().height
        pickerView.frame = pickerFrame
        
        UIApplication.sharedApplication().windows.last?.addSubview(pickerView)
        
        UIView.animateWithDuration(0.2) {
            pickerFrame.origin.y -= pickerFrame.size.height
            pickerView.frame = pickerFrame
        }
    }
    
    func removePickerView() {
        background.removeFromSuperview()
        
        var pickerView: OptionPickerView
        switch viewModel.option {
        case .Repositories:
            pickerView = repoOptionsPickerView
        case .Users:
            pickerView = userOptionPickerView
        }
        
        UIView.animateWithDuration(0.2, animations: {
            var frame = pickerView.frame
            frame.origin.y += pickerView.frame.height
            pickerView.frame = frame
        }) { _ in
            pickerView.clearRecord()
            pickerView.removeFromSuperview()
        }
    }
}

extension SearchViewController: OptionPickerViewDelegate {
    
    func doneButtonClicked() {
        removePickerView()
        
        var pickerView: OptionPickerView
        switch viewModel.option {
        case .Repositories:
            pickerView = repoOptionsPickerView
            
            let row0 = pickerView.tmpSelectedRow[0] ?? pickerView.selectedRow[0]
            let row1 = pickerView.tmpSelectedRow[1] ?? pickerView.selectedRow[1]
            
            pickerView.selectedRow[0] = row0
            pickerView.selectedRow[1] = row1
            
            viewModel.option = .Repositories(sort: viewModel.reposSortOptions[row0].option, language: languages[row1])
        case .Users:
            pickerView = userOptionPickerView
            
            let row = pickerView.tmpSelectedRow[0] ?? pickerView.selectedRow[0]
            pickerView.selectedRow[0] = row
            viewModel.option = .Users(sort: viewModel.usersSortOptions[row].option)
        }
        
        
        updateTitle()
        pickerView.clearRecord()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch viewModel.option {
        case .Repositories:
            return repoOptionsPickerView.index == 0 ? 4 : languages.count
        case .Users:
            return 4
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch viewModel.option {
        case .Repositories:
            return repoOptionsPickerView.index == 0 ?
                viewModel.reposSortOptions.map {$0.desc} [row] :
                languages[row]
        case .Users:
            return viewModel.usersSortOptions.map {$0.desc} [row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var pickerView: OptionPickerView
        switch viewModel.option {
        case .Repositories:
            pickerView = repoOptionsPickerView
        case .Users:
            pickerView = userOptionPickerView
        }
        pickerView.tmpSelectedRow[pickerView.index] = row
    }
}
