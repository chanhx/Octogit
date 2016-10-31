//
//  GistViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/15/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxSwift

class GistViewController: BaseTableViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var infoLabel: UILabel!
    
    var viewModel: GistViewModel! {
        didSet {
            viewModel.fetchData()
            
            viewModel.dataSource.asDriver()
                .drive(onNext: { [unowned self] _ in
                    self.tableView.reloadData()
                    
                    self.sizeHeaderToFit(tableView: self.tableView)
                })
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    class func instantiateFromStoryboard() -> GistViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GistViewController") as! GistViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHeader()
        sizeHeaderToFit(tableView: tableView)
    }
    
    func configureHeader() {
        
        titleLabel.text = viewModel.gist.files?[0].name
        
        avatarView.setAvatar(with: viewModel.gist.owner?.avatarURL)
        
        let attrInfo = NSMutableAttributedString(string: "\(viewModel.gist.owner!) created \(viewModel.gist.createdAt!.naturalString)")
        attrInfo.addAttributes([
            NSForegroundColorAttributeName: UIColor(netHex: 0x555555),
            NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
            ],
                               range: NSRange(location: 0, length: viewModel.gist.owner!.login!.characters.count))
        
        infoLabel.attributedText = attrInfo
    }
    
    // MARK: table view
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Files"
        default:
            if viewModel.dataSource.value.count > 0 {
                return "Comments"
            }
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            cell.textLabel?.textColor = UIColor(netHex: 0x333333)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = viewModel.gist.files?[indexPath.row].name
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            cell.selectionStyle = .none
            cell.entity = viewModel.dataSource.value[indexPath.row]
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.section == 0 else {
            return
        }
        
        let fileTVC = FileViewController()
        fileTVC.viewModel = FileViewModel(file: viewModel.gist.files![indexPath.row])
        navigationController?.pushViewController(fileTVC, animated: true)
    }
}
