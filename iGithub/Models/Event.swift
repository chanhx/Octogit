
//
//  Event.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftDate

enum EventType: String {
    case commitCommentEvent = "CommitCommentEvent"
    case createEvent = "CreateEvent"
    case deleteEvent = "DeleteEvent"
    case deploymentEvent = "DeploymentEvent"                    // not visible
    case deploymentStatusEvent = "DeploymentStatusEvent"        // not visible
    case downloadEvent = "DownloadEvent"                        // no longer created
    case followEvent = "FollowEvent"                            // no longer created
    case forkEvent = "ForkEvent"
    case forkApplyEvent = "ForkApplyEvent"                      // no longer created
    case gistEvent = "GistEvent"                                // no longer created
    case gollumEvent = "GollumEvent"
    case issueCommentEvent = "IssueCommentEvent"
    case issuesEvent = "IssuesEvent"
    case memberEvent = "MemberEvent"
    case membershipEvent = "MembershipEvent"                    // not visible
    case pageBuildEvent = "PageBuildEvent"                      // not visible
    case publicEvent = "PublicEvent"
    case pullRequestEvent = "PullRequestEvent"
    case pullRequestReviewCommentEvent = "PullRequestReviewCommentEvent"
    case pushEvent = "PushEvent"
    case releaseEvent = "ReleaseEvent"
    case repositoryEvent = "RepositoryEvent"                    // not visible
    case statusEvent = "StatusEvent"                            // not visible
    case teamAddEvent = "TeamAddEvent"
    case watchEvent = "WatchEvent"
}

class Event: BaseModel, StaticMappable {
    
    var id: Int?
    var type: EventType?
    var repository: String?
    var actor: User?
    var org: User?
    var createdAt: Date?
    
    static func objectForMapping(map: ObjectMapper.Map) -> BaseMappable? {
        if let type: EventType = EventType(rawValue: map["type"].value()!) {
            switch type {
            case .commitCommentEvent: return CommitCommentEvent(map: map)
            case .createEvent: return CreateEvent(map: map)
            case .deleteEvent: return DeleteEvent(map: map)
            case .forkEvent: return ForkEvent(map: map)
            case .gollumEvent: return GollumEvent(map: map)
            case .issueCommentEvent: return IssueCommentEvent(map: map)
            case .issuesEvent: return IssueEvent(map: map)
            case .memberEvent: return MemberEvent(map: map)
            case .publicEvent: return PublicEvent(map: map)
            case .pullRequestEvent: return PullRequestEvent(map: map)
            case .pullRequestReviewCommentEvent: return PullRequestReviewCommentEvent(map: map)
            case .pushEvent: return PushEvent(map: map)
            case .releaseEvent: return ReleaseEvent(map: map)
            case .watchEvent: return WatchEvent(map: map)
            default: return nil
            }
        }
        
        return nil
    }
    
    override func mapping(map: Map) {
        id              <- (map["id"], IntTransform())
        type            <- map["type"]
        repository  <- map["repo.name"]
        actor           <- (map["actor"], UserTransform())
        org             <- (map["org"], UserTransform())
        createdAt       <- (map["created_at"], DateTransform())
    }
}

// MARK: CommitCommentEvent

class CommitCommentEvent : Event {
    var comment: CommitComment?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        comment <- map["payload.comment"]
    }
}

enum RefType : String {
    case Branch = "branch"
    case Tag = "tag"
    case Repository = "repository"
}

// MARK: CreateEvent

class CreateEvent: Event {
    var refType: RefType?
    var ref: String?
    var repoDescription: String?
        
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        refType         <- map["payload.ref_type"]
        ref             <- map["payload.ref"]
        repoDescription <- map["payload.description"]
    }
}

// MARK: DeleteEvent

class DeleteEvent: Event {
    var refType: RefType?
    var ref: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        refType         <- map["payload.ref_type"]
        ref             <- map["payload.ref"]
    }
}

// MARK: ForkEvent

class ForkEvent: Event {
    var forkee: String?
    var forkeeDescription: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        forkee <- map["payload.forkee.full_name"]
        forkeeDescription <- map["payload.forkee.description"]
    }
}

// MARK: GollumEvent

class GollumEvent: Event {
    var pageName: String?
    var action: String?
    var summary: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        pageName <- map["payload.pages.0.page_name"]
        action   <- map["payload.pages.0.action"]
        summary  <- map["payload.pages.0.summary"]
    }
}

// MARK: IssueCommentEvent

class IssueCommentEvent : Event {
    var action: String?
    var issue: Issue?
    var comment: IssueComment?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        action <- map["payload.action"]
        issue <- (map["payload.issue"], IssueTransform())
        comment <- (map["payload.comment"], IssueCommentTransform())
    }
}

// MARK: IssueEvent

enum IssueAction: String {
    case Assigned = "assigned"
    case Unassigned = "unassigned"
    case Labeled = "labeled"
    case Unlabeled = "unlabeled"
    case Opened = "opened"
    case Edited = "edited"
    case Closed = "closed"
    case Reopened = "reopened"
}

class IssueEvent: Event {
    var issue: Issue?
    var action: IssueAction?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        issue <- (map["payload.issue"], IssueTransform())
        action <- map["payload.action"]
    }
}

// MARK: MemberEvent

class MemberEvent: Event {
    var member: User?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        member <- (map["payload.member"], UserTransform())
    }
}

// MARK: PublicEvent

class PublicEvent: Event {
    var repositoryDescription: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        repositoryDescription <- map["payload.repository.description"]
    }
}

// MARK: PullRequestEvent

class PullRequestEvent : Event {
    var pullRequest: PullRequest?
    var action: IssueAction?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        pullRequest <- (map["payload.pull_request"], PullRequestTransform())
        action <- map["payload.action"]
    }
}

// MARK: PullRequestCommentEvent

class PullRequestReviewCommentEvent : Event {
    var action: String?
    var comment: PullRequestComment?
    var pullRequest : PullRequest?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        action  <- map["payload.action"]
        comment <- (map["payload.comment"], PullRequestCommentTransform())
    }
}

// MARK: PushEvent

class PushEvent : Event {
    var ref: String?
    var commitCount: Int?
    var distinctCommitCount: Int?
    var previousHeadSHA: String?
    var currentHeadSHA: String?
    var branchName: String?
    var commits: [EventCommit]?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        ref                 <- map["payload.ref"]
        commitCount         <- map["payload.size"]
        distinctCommitCount <- map["payload.distinct_size"]
        previousHeadSHA     <- map["payload.before"]
        currentHeadSHA      <- map["payload.head"]
        branchName          <- map["payload.ref"]
        commits             <- (map["payload.commits"], EventCommitTransform())
    }
}

// MARK: ReleaseEvent

class ReleaseEvent: Event {
    var releaseTagName: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        releaseTagName <- map["payload.release.tag_name"]
    }
}

// MARK: WatchEvent

class WatchEvent : Event {
    var action: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        action <- map["payload.action"]
    }
}
