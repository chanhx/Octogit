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
        
        return sectionTypes.count
    }
    
    override func numberOfRowsIn(section: Int) -> Int {
        guard userLoaded else {
            return 1
        }
        
        switch sectionTypes[section] {
        case .vcards:
            return vcardDetails.count
        case .general:
            return 3
        default:
            return 0
        }
    }
}
