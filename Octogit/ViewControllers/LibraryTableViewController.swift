//
//  LibraryTableViewController.swift
//  Octogit
//
//  Created by Chan Hocheung on 31/10/2016.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import ObjectMapper

class LibraryTableViewController: BaseTableViewController {
    
    let dataSource: [Repository] = {
        let url = Bundle.main.url(forResource: "libraries", withExtension: "json")
        let json = try! String(contentsOf: url!, encoding: .utf8)
        
        return Mapper<Repository>().mapArray(JSONString: json)!
    }()

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryCell", for: indexPath) as! LibraryCell
        let repo = dataSource[indexPath.row]
        
        cell.entity = repo

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        let repo = dataSource[indexPath.row]
        let repoVC = RepositoryViewController.instantiateFromStoryboard()
        repoVC.viewModel = RepositoryViewModel(repo: repo.nameWithOwner!)
        
        navigationController?.pushViewController(repoVC, animated: true)
    }
 
}
