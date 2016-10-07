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
    let disposeBag = DisposeBag()
    
    var page: Int = 1
    
    func fetchData() {}
    
    @objc func refresh() {
        page = 1
        fetchData()
    }
    
    @objc func fetchNextPage() {
        page = dataSource.value.count / 30 + 1
        fetchData()
    }
}
