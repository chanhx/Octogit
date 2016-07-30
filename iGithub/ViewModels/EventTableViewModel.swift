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
    
    init(username: String, type: UserEventType) {
        switch type {
        case .Performed:
            token = .UserEvents(username: username)
        case .Received:
            token = .ReceivedEvents(username: username)
        }
    }
    
    override func fetchData() {
        provider
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
    
    func repositoryViewModelForIndex(index: Int) -> RepositoryViewModel {
        return RepositoryViewModel(fullName: dataSource.value[index].repositoryName!)
    }
}