//
//  FilesViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/25/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

class FilesViewController: BaseTableViewController {
    
    var viewModel: FilesTableViewModel! {
        didSet {
            viewModel.dataSource.asObservable()
                .bindTo(tableView.rx_itemsWithCellIdentifier("FileCell", cellType: FileCell.self)) { row, element, cell in
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
        
        self.navigationItem.title = viewModel.title
        
        viewModel.fetchData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        let file = viewModel.dataSource.value[indexPath.row]
        if file.type! == .File {
            let fileVC = FileViewController()
            fileVC.viewModel = viewModel.fileViewModel(file)
            self.navigationController?.pushViewController(fileVC, animated: true)
        } else {
            let filesTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FileTVC") as! FilesViewController
            filesTableVC.viewModel = viewModel.subDirectoryViewModel(file)
            self.navigationController?.pushViewController(filesTableVC, animated: true)
        }
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let repositoryVM = viewModel.repositoryViewModelForIndex(tableView.indexPathForSelectedRow!.row)
//        let repositoryVC = segue.destinationViewController as! RepositoryViewController
//        repositoryVC.viewModel = repositoryVM
//    }
}