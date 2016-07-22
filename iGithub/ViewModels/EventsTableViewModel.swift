//
//  EventsTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class EventsTableViewModel: BaseTableViewModel<Event> {
    
    override func fetchData() {
        provider
            .request(.ReceivedEvents(username: AccountManager.shareManager.currentUser!.login!))
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
}