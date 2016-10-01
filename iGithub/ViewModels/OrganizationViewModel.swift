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
        token = .organization(org: organization.login!)
    }
    
    override init(_ orgName: String) {
        super.init(orgName)
        token = .organization(org: orgName)
    }
    
    override var numberOfSections: Int {
        guard userLoaded else {
            return 1
        }
        
        return details.count > 0 ? 2 : 1
    }
    
    override func numberOfRowsInSection(_ section: Int) -> Int {
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
