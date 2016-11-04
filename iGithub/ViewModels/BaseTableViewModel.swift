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

class BaseTableViewModel<T> {
    
    var dataSource: Variable<[T]> = Variable([])
    let error = Variable<Swift.Error?>(nil)
    let disposeBag = DisposeBag()
    
    var page: Int = 1
    var hasNextPage = true
    
    @objc func fetchData() {}
    
    @objc func refresh() {
        page = 1
        hasNextPage = true
        fetchData()
    }
}
