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
    let provider = RxMoyaProvider<GithubAPI>()
    let disposeBag = DisposeBag()
    
    func fetchData() {}
}
