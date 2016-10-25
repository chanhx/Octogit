//
//  GistViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/15/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

class GistViewModel: BaseTableViewModel<Comment> {
    
    var gist: Gist
    
    init(gist: Gist) {
        self.gist = gist
        
        super.init()
    }
    
    override func fetchData() {
        let token = GithubAPI.gistComments(gistID: gist.id!, page: page)
        
        GithubProvider
            .request(token)
            .do(onNext: {
                if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newComments = Mapper<Comment>().mapArray(JSONObject: $0) {
                        self.dataSource.value.append(contentsOf: newComments)
                    }
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .addDisposableTo(disposeBag)
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        switch section {
        case 0:
            return gist.files!.count
        default:
            return dataSource.value.count
        }
    }
}
