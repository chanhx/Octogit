//
//  FileTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/25/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

class FileTableViewController: BaseTableViewController {
    
    var viewModel: FileTableViewModel! {
        didSet {
            viewModel.dataSource.asObservable()
                .skip(1)
                .do(onNext: { _ in
                    self.tableView.refreshHeader?.endRefreshing()
                })
                .bindTo(tableView.rx.items(cellIdentifier: "FileCell", cellType: FileCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
            
//            tableView
//                .rx_itemSelected
//                .map { indexPath in
//                    return self.viewModel.dataSource.value[indexPath.row]
//                }
//                .subscribeNext { file in
//                    
//                }
//                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.title
        
        tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
        
        tableView.refreshHeader?.beginRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let file = viewModel.dataSource.value[indexPath.row]
        if file.type! == .file {
            let fileVC = FileViewController()
            fileVC.viewModel = viewModel.fileViewModel(file)
            self.navigationController?.pushViewController(fileVC, animated: true)
        } else {
            let fileTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FileTVC") as! FileTableViewController
            fileTVC.viewModel = viewModel.subDirectoryViewModel(file)
            self.navigationController?.pushViewController(fileTVC, animated: true)
        }
    }
    
}
