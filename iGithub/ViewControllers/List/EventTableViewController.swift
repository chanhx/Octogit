//
//  EventTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift
import TTTAttributedLabel

class EventTableViewController: BaseTableViewController, TTTAttributedLabelDelegate {
    
    let disposeBag = DisposeBag()
    
    var viewModel: EventTableViewModel! {
        didSet {
            viewModel.dataSource.asDriver()
                .skip(1)
                .do(onNext: { [unowned self] _ in
                    self.tableView.refreshHeader?.endRefreshing()
                    self.viewModel.hasNextPage ?
                        self.tableView.refreshFooter?.endRefreshing() :
                        self.tableView.refreshFooter?.endRefreshingWithNoMoreData()
                })
                .drive(tableView.rx.items(cellIdentifier: "EventCell", cellType: EventCell.self)) { [weak self] row, element, cell in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    cell.configure(withEvent: element)
                    cell.titleLabel.delegate = strongSelf
                    cell.contentLabel.delegate = strongSelf
                    cell.selectionStyle = .none
                    
                    cell.titleLabel.tag = row
                    cell.avatarView.tag = row
                    cell.avatarView.addGestureRecognizer(UITapGestureRecognizer(target: strongSelf, action: #selector(strongSelf.avatarTapped)))
                }
                .addDisposableTo(disposeBag)
            
            viewModel.error.asDriver()
                .filter {
                    $0 != nil
                }
                .drive(onNext: { [unowned self] in
                    self.tableView.refreshHeader?.endRefreshing()
                    self.tableView.refreshFooter?.endRefreshing()
                    MessageManager.show(error: $0!)
                })
                .addDisposableTo(disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = viewModel.title
        
        tableView.register(EventCell.self, forCellReuseIdentifier: "EventCell")
        
        tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
        tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchData))
        
        tableView.refreshHeader?.beginRefreshing()
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let row = label.tag
        let user = viewModel.dataSource.value[row].actor!
        
        if url.absoluteString == "/\(user)" {
            showUser(user)
            return
        }
        
        let vc = URLRouter.viewController(forURL: url)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func avatarTapped(_ recognizer: UITapGestureRecognizer) {
        let row = recognizer.view?.tag
        let user = viewModel.dataSource.value[row!].actor!
        showUser(user)
    }
    
    func showUser(_ user: User) {
        let userVC = UserViewController.instantiateFromStoryboard()
        userVC.viewModel = UserViewModel(user)
        navigationController?.pushViewController(userVC, animated: true)
    }
    
}
