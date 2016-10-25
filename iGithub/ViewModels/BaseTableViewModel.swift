//
//  BaseTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxMoya
import RxSwift
import ObjectMapper

class BaseTableViewModel<T: BaseModel> {
    
    var dataSource: Variable<[T]> = Variable([])
    let error = Variable<Swift.Error?>(nil)
    let disposeBag = DisposeBag()
    
    var page: Int = 1
    var hasNextPage = true
    
    func fetchData() {}
    
    @objc func refresh() {
        page = 1
        fetchData()
    }
    
    @objc func fetchNextPage() {
        page += 1
        fetchData()
    }
}
