//
//  Transforms.swift
//  Octogit
//
//  Created by Chan Hocheung on 28/10/2016.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class IntTransform: TransformOf<Int, String> {
    init() {
        super.init(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } })
    }
}

class GistFilesTransform: TransformOf<[GistFile], AnyObject> {
    init() {
        super.init(
            fromJSON: {
                Mapper<GistFile>().mapDictionary(JSON: $0 as! [String : [String : Any]])?
                    .values
                    .sorted { (f1, f2) -> Bool in
                        f1.name! < f2.name!
                }
            }, toJSON: {
//                $0?.reduce([String: GistFile]()) { (var dict, file) in
//                    dict[file.name!] = file
//                    return dict
//                } as AnyObject
                String(describing: $0) as AnyObject
        })
    }
}
