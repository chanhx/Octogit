//
//  BaseModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseModel: Mappable {
    
    required init?(map: Map) {}
    func mapping(map: Map) {}
}

class IntTransform: TransformOf<Int, String> {
    init() {
        super.init(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } })
    }
}

class UserTransform: TransformOf<User, AnyObject> {
    init() {
        super.init(fromJSON: { Mapper<User>().map(JSON: $0 as! [String : Any]) }, toJSON: { String(describing: $0) as AnyObject })
    }
}

class DateTransform: TransformOf<Date, String> {
    init() {
        super.init(fromJSON: { $0?.toDate(format: .iso8601Format(.full)) }, toJSON: { String(describing: $0) })
    }
}

class IssueTransform: TransformOf<Issue, String> {
    init() {
        super.init(fromJSON: { Mapper<Issue>().map(JSONObject: $0) }, toJSON: { String(describing: $0) })
    }
}

class IssueCommentTransform: TransformOf<IssueComment, String> {
    init() {
        super.init(fromJSON: { Mapper<IssueComment>().map(JSONObject: $0) }, toJSON: { String(describing: $0) })
    }
}

class PullRequestTransform: TransformOf<PullRequest, String> {
    init() {
        super.init(fromJSON: { Mapper<PullRequest>().map(JSONObject: $0) }, toJSON: { String(describing: $0) })
    }
}

class PullRequestCommentTransform: TransformOf<PullRequestComment, String> {
    init() {
        super.init(fromJSON: { Mapper<PullRequestComment>().map(JSONObject: $0) }, toJSON: { String(describing: $0) })
    }
}

class RepositoryTransform: TransformOf<Repository, String> {
    init() {
        super.init(fromJSON: { Mapper<Repository>().map(JSONObject: $0) }, toJSON: { String(describing: $0) })
    }
}

class EventCommitTransform: TransformOf<EventCommit, String> {
    init() {
        super.init(fromJSON: { Mapper<EventCommit>().map(JSONObject: $0) }, toJSON: { String(describing: $0) })
    }
}

class LabelTransform: TransformOf<Label, String> {
    init() {
        super.init(fromJSON: { Mapper<Label>().map(JSONObject: $0) }, toJSON: { String(describing: $0) })
    }
}

class GistFileTransform: TransformOf<GistFile, String> {
    init() {
        super.init(fromJSON: { Mapper<GistFile>().map(JSONObject: $0) }, toJSON: { String(describing: $0) })
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
