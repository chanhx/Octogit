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
    
    required init?(_ map: Map) {}
    class func objectForMapping(map: ObjectMapper.Map) -> Mappable? { return nil }
    func mapping(map: Map) {}
}

class IntTransform: TransformOf<Int, String> {
    init() {
        super.init(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } })
    }
}

class UserTransform: TransformOf<User, AnyObject> {
    init() {
        super.init(fromJSON: { Mapper<User>().map($0) }, toJSON: { String($0) })
    }
}

class DateTransform: TransformOf<NSDate, String> {
    init() {
        super.init(fromJSON: { $0?.toDate(.ISO8601Format(.Full)) }, toJSON: { String($0) })
    }
}

class IssueTransform: TransformOf<Issue, AnyObject> {
    init() {
        super.init(fromJSON: { Mapper<Issue>().map($0) }, toJSON: { String($0) })
    }
}

class IssueCommentTransform: TransformOf<IssueComment, AnyObject> {
    init() {
        super.init(fromJSON: { Mapper<IssueComment>().map($0) }, toJSON: { String($0) })
    }
}

class PullRequestTransform: TransformOf<PullRequest, AnyObject> {
    init() {
        super.init(fromJSON: { Mapper<PullRequest>().map($0) }, toJSON: { String($0) })
    }
}

class PullRequestCommentTransform: TransformOf<PullRequestComment, AnyObject> {
    init() {
        super.init(fromJSON: { Mapper<PullRequestComment>().map($0) }, toJSON: { String($0) })
    }
}

class RepositoryTransform: TransformOf<Repository, AnyObject> {
    init() {
        super.init(fromJSON: { Mapper<Repository>().map($0) }, toJSON: { String($0) })
    }
}
