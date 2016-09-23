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
    case performed
    case received
}

class EventTableViewModel: BaseTableViewModel<Event> {
    
    fileprivate var token: GithubAPI
    var page: Int = 1 {
        didSet {
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
        }
    }
    
    init(user: User, type: UserEventType) {
        switch type {
        case .performed:
            token = .userEvents(user: user.login!, page: page)
        case .received:
            token = .receivedEvents(user: user.login!, page: page)
        }
    }
    
    init(repo: Repository) {
        token = .repositoryEvents(repo: repo.fullName!, page: page)
    }
    
    init(org: User) {
        token = .organizationEvents(org: org.login!, page: page)
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newEvents = Mapper<Event>().mapArray(JSONObject: $0) {
                        if self.page == 1 {
                            self.dataSource.value = newEvents
                        } else {
                            self.dataSource.value.append(contentsOf: newEvents)
                        }
                    }
                },
                onError: {
                    print($0)
            })
            .addDisposableTo(disposeBag)
    }
    
    @objc func refresh() {
        page = 1
        fetchData()
    }
    
    @objc func fetchNextPage() {
        page = dataSource.value.count / 30 + 1
        fetchData()
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
