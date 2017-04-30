//
//  EventTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift
import Moya

enum UserEventType {
    case performed
    case received
}

class EventTableViewModel: BaseTableViewModel<Event> {
    
    private var token: GitHubAPI
    
    init(user: User, type: UserEventType) {
        switch type {
        case .performed:
            token = .userEvents(user: user.login!, page: 1)
        case .received:
            token = .receivedEvents(user: user.login!, page: 1)
        }
        
        super.init()
    }
    
    init(repo: Repository) {
        token = .repositoryEvents(repo: repo.fullName!, page: 1)
        
        super.init()
    }
    
    init(org: User) {
        token = .organizationEvents(org: org.login!, page: 1)
        
        super.init()
    }
    
    override func fetchData() {
        switch token {
        case .userEvents(let user, _):
            token = .userEvents(user: user, page: page)
        case .receivedEvents(let user, _):
            token = .receivedEvents(user: user, page: page)
        case .repositoryEvents(let repo, _):
            token = .repositoryEvents(repo: repo, page: page)
        case .organizationEvents(let org, _):
            token = .organizationEvents(org: org, page: page)
        default:
            break
        }
        
        GitHubProvider
            .request(token)
            .filterSuccessfulStatusAndRedirectCodes()
            .do(onNext: { [unowned self] in
                if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(
                onNext: { [unowned self] in
                    if let newEvents = Mapper<Event>().mapArray(JSONObject: $0) {
                        if self.page == 1 {
                            self.dataSource.value = newEvents
                        } else {
                            self.dataSource.value.append(contentsOf: newEvents)
                        }
                        
                        self.page += 1
                    }
                },
                onError: { [unowned self] in
                    self.error.value = $0
                }
            )
            .addDisposableTo(disposeBag)
    }
    
    var title: String {
        switch token {
        case .receivedEvents:
            return "News"
        default:
            return "Recent activity"
        }
    }
    
}
