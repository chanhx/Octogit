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
    case CommitCommentEvent = "CommitCommentEvent"
    case CreateEvent = "CreateEvent"
    case DeleteEvent = "DeleteEvent"
    case DeploymentEvent = "DeploymentEvent"                    // not visible
    case DeploymentStatusEvent = "DeploymentStatusEvent"        // not visible
    case DownloadEvent = "DownloadEvent"                        // no longer created
    case FollowEvent = "FollowEvent"                            // no longer created
    case ForkEvent = "ForkEvent"
    case ForkApplyEvent = "ForkApplyEvent"                      // no longer created
    case GistEvent = "GistEvent"                                // no longer created
    case GollumEvent = "GollumEvent"
    case IssueCommentEvent = "IssueCommentEvent"
    case IssuesEvent = "IssuesEvent"
    case MemberEvent = "MemberEvent"
    case MembershipEvent = "MembershipEvent"                    // not visible
    case PageBuildEvent = "PageBuildEvent"                      // not visible
    case PublicEvent = "PublicEvent"
    case PullRequestEvent = "PullRequestEvent"
    case PullRequestReviewCommentEvent = "PullRequestReviewCommentEvent"
    case PushEvent = "PushEvent"
    case ReleaseEvent = "ReleaseEvent"
    case RepositoryEvent = "RepositoryEvent"                    // not visible
    case StatusEvent = "StatusEvent"                            // not visible
    case TeamAddEvent = "TeamAddEvent"
    case WatchEvent = "WatchEvent"
}

class Event: BaseModel, StaticMappable {
    
    var id: Int?
    var type: EventType?
    var repository: String?
    var actor: User?
    var org: User?
    var createdAt: NSDate?
    
    static func objectForMapping(map: ObjectMapper.Map) -> Mappable? {
        if let type: EventType = EventType(rawValue: map["type"].value()!) {
            switch type {
            case .CommitCommentEvent: return CommitCommentEvent(map)
            case .CreateEvent: return CreateEvent(map)
            case .DeleteEvent: return DeleteEvent(map)
            case .ForkEvent: return ForkEvent(map)
            case .GollumEvent: return GollumEvent(map)
            case .IssueCommentEvent: return IssueCommentEvent(map)
            case .IssuesEvent: return IssueEvent(map)
            case .MemberEvent: return MemberEvent(map)
            case .PublicEvent: return PublicEvent(map)
            case .PullRequestEvent: return PullRequestEvent(map)
            case .PullRequestReviewCommentEvent: return PullRequestReviewCommentEvent(map)
            case .PushEvent: return PushEvent(map)
            case .ReleaseEvent: return ReleaseEvent(map)
            case .WatchEvent: return WatchEvent(map)
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
        super.mapping(map)
        
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
        super.mapping(map)
        
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
        super.mapping(map)
        
        refType         <- map["payload.ref_type"]
        ref             <- map["payload.ref"]
    }
}

// MARK: ForkEvent

class ForkEvent: Event {
    var forkee: String?
    var forkeeDescription: String?
    
    override func mapping(map: Map) {
        super.mapping(map)
        
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
        super.mapping(map)
        
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
        super.mapping(map)
        
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
        super.mapping(map)
        
        issue <- (map["payload.issue"], IssueTransform())
        action <- map["payload.action"]
    }
}

// MARK: MemberEvent

class MemberEvent: Event {
    var member: User?
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        member <- (map["payload.member"], UserTransform())
    }
}

// MARK: PublicEvent

class PublicEvent: Event {
    var repositoryDescription: String?
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        repositoryDescription <- map["payload.repository.description"]
    }
}

// MARK: PullRequestEvent

class PullRequestEvent : Event {
    var pullRequest: PullRequest?
    var action: IssueAction?
    
    override func mapping(map: Map) {
        super.mapping(map)
        
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
        super.mapping(map)
        
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
    var commits: [CommitsItem]?
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        ref                 <- map["payload.ref"]
        commitCount         <- map["payload.size"]
        distinctCommitCount <- map["payload.distinct_size"]
        previousHeadSHA     <- map["payload.before"]
        currentHeadSHA      <- map["payload.head"]
        branchName          <- map["payload.ref"]
        commits             <- (map["payload.commits"], CommitItemTransform())
    }
}

// MARK: ReleaseEvent

class ReleaseEvent: Event {
    var releaseTagName: String?
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        releaseTagName <- map["payload.release.tag_name"]
    }
}

// MARK: WatchEvent

class WatchEvent : Event {
    var action: String?
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        action <- map["payload.action"]
    }
}
