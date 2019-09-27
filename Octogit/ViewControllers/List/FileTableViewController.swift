//
//  FileTableViewController.swift
//  Octogit
//
//  Created by Chan Hocheung on 7/25/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

class FileTableViewController: BaseTableViewController {
    
    var viewModel: FileTableViewModel! {
        didSet {
            viewModel.dataSource.asDriver()
                .skip(1)
                .do(onNext: { [unowned self] _ in
                    self.tableView.refreshHeader?.endRefreshingWithNoMoreData()
                })
                .drive(tableView.rx.items(cellIdentifier: "FileCell", cellType: FileCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .disposed(by: viewModel.disposeBag)            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.title
        
        tableView.register(FileCell.self, forCellReuseIdentifier: "FileCell")
        
        tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
        
        tableView.refreshHeader?.beginRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let file = viewModel.dataSource.value[indexPath.row]
        
        switch file.type! {
        case .submodule:
            guard let _ = file.gitLink else {
                MessageManager.showMessage(title: "", body: "The submodule repository is not hosted on github.com", type: .info)
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            
            let fileVC = FileTableViewController()
            fileVC.viewModel = viewModel.submoduleViewModel(file)
            self.navigationController?.pushViewController(fileVC, animated: true)
        case .directory:
            let fileTVC = FileTableViewController()
            fileTVC.viewModel = viewModel.subDirectoryViewModel(file)
            self.navigationController?.pushViewController(fileTVC, animated: true)
        default:
            let fileVC = FileViewController()
            fileVC.viewModel = viewModel.fileViewModel(file)
            self.navigationController?.pushViewController(fileVC, animated: true)
        }
    }
    
}
