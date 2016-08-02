//
//  IssueViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

class IssueViewModel: NSObject {

    var issue: Issue
    
    init(issue: Issue) {
        self.issue = issue
        super.init()
    }
    
//    func numberOfRowsInSection(section: Int) -> Int {
//        
//        switch section {
//        case 0:
//            return details.count
//        case 1:
//            return events.count
//        default:
//            return 0
//        }
//    }
    
}
