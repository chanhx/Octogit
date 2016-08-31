//
//  EventTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

enum UserEventType {
    case Performed
    case Received
}

class EventTableViewModel: BaseTableViewModel<Event> {
    
    private var token: GithubAPI
    var page: Int = 1 {
        didSet {
            switch token {
            case .UserEvents(let user, _):
                token = .UserEvents(user: user, page: page)
            case .ReceivedEvents(let user, _):
                token = .ReceivedEvents(user: user, page: page)
            case .RepositoryEvents(let repo, _):
                token = .RepositoryEvents(repo: repo, page: page)
            case .OrganizationEvents(let org, _):
                token = .OrganizationEvents(org: org, page: page)
            default:
                break
            }
        }
    }
    
    init(user: User, type: UserEventType) {
        switch type {
        case .Performed:
            token = .UserEvents(user: user.login!, page: page)
        case .Received:
            token = .ReceivedEvents(user: user.login!, page: page)
        }
    }
    
    init(repo: Repository) {
        token = .RepositoryEvents(repo: repo.fullName!, page: page)
    }
    
    init(org: User) {
        token = .OrganizationEvents(org: org.login!, page: page)
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newEvents = Mapper<Event>().mapArray($0) {
                        self.dataSource.value.appendContentsOf(newEvents)
                    }
                },
                onError: {
                    print($0)
            })
            .addDisposableTo(disposeBag)
    }
    
    @objc func fetchNextPage() {
        page = dataSource.value.count / 30 + 1
        fetchData()
    }
    
    var title: String {
        switch token {
        case .ReceivedEvents:
            return "News"
        default:
            return "Recent activity"
        }
    }
    
}