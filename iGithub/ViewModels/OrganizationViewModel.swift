//
//  OrganizationViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import RxMoya
import RxSwift
import ObjectMapper

class OrganizationViewModel: UserViewModel {
    
    override init(_ organization: User) {
        super.init(organization)
        token = .Organization(org: organization.login!)
    }
    
    override init(_ orgName: String) {
        super.init(orgName)
        token = .Organization(org: orgName)
    }
    
    override var numberOfSections: Int {
        guard userLoaded else {
            return 1
        }
        var sections = 1
        let o = user.value
        
        if o.company != nil {details.append(.Company)}
        if o.location != nil {details.append(.Location)}
        if o.email != nil {details.append(.Email)}
        if o.blog != nil {details.append(.Blog)}
        
        if details.count > 0 {sections += 1}
        
        return sections
    }
    
    override func numberOfRowsInSection(section: Int) -> Int {
        guard userLoaded else {
            return 1
        }
        
        switch (section, details.count) {
        case (0, 1...4):
            return details.count
        case (0, 0), (1, _):
            return 3
        default:
            return 0
        }
    }
}
