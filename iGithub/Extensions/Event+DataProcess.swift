//
//  Event+DataProcess.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/24/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

extension Event {
    
    var title: String {
        switch self.type! {
        case .CommitCommentEvent:
            let e = self as! CommitCommentEvent
            let commitID = e.comment!.commitID!
            let shortenedSHA = commitID.substringToIndex(commitID.startIndex.advancedBy(7))
            return "\(e.actor!) commented on \(shortenedSHA) at \(e.repositoryName!)"
        case .CreateEvent:
            let e = self as! CreateEvent
            switch e.refType! {
            case .Repository:
                return "\(e.actor!) created \(e.refType!.rawValue) \(e.repositoryName!)"
            default:
                return "\(e.actor!) created \(e.refType!.rawValue) \(e.ref!) at \(e.repositoryName!)"
            }
        case .DeleteEvent:
            let e = self as! DeleteEvent
            return "\(e.actor!) deleted \(e.refType?.rawValue) \(e.ref!) at \(e.repositoryName!)"
        case .ForkEvent:
            let e = self as! ForkEvent
            return "\(e.actor!) forked \(e.repositoryName!) to \(e.forkeeFullName!)"
        case .GollumEvent:
            let e = self as! GollumEvent
            return "\(e.actor!) \(e.action!) \(e.pageName) in the \(e.repositoryName!) wiki"
        case .IssueCommentEvent:
            let e = self as! IssueCommentEvent
            return "\(e.actor!) \(e.action!) comment on issue \(e.repositoryName!)#\(e.issue!.id!)"
        case .IssuesEvent:
            let e = self as! IssueEvent
            return "\(e.actor!) \(e.action!) issue \(e.repositoryName!)#\(e.issue!.id!)"
        case .MemberEvent:
            let e = self as! MemberEvent
            return "\(e.actor!) added \(e.member!) to \(e.repositoryName!)"
        case .PublicEvent:
            return "\(self.actor!) open-sourced \(self.repositoryName!)"
        case .PullRequestEvent:
            let e = self as! PullRequestEvent
            var action: String
            if e.action! == .Closed && e.pullRequest!.isMerged! {
                action = "merged"
            } else {
                action = e.action!.rawValue
            }
            return "\(e.actor!) \(action) pull request \(e.repositoryName!)#\(e.pullRequest!.id!)"
        case .PullRequestReviewCommentEvent:
            let e = self as! PullRequestReviewCommentEvent
            return "\(e.actor!) \(e.action) comment on issue \(e.repositoryName!)#\(e.pullRequest!.id!)"
        case .PushEvent:
            let e = self as! PushEvent
            return "\(e.actor!) pushed to \(e.ref!) at \(e.repositoryName!)"
        case .ReleaseEvent:
            let e = self as! ReleaseEvent
            return "\(e.actor) released \(e.releaseTagName) at \(e.repositoryName)"
        case .WatchEvent:
            return "\(self.actor!) starred \(self.repositoryName!)"
        default:
            return ""
        }
    }
    
    var content: String? {
        switch self.type! {
        case .CommitCommentEvent:
            let e = self as! CommitCommentEvent
            return e.comment!.body!
        case .CreateEvent:
            let e = self as! CreateEvent
            switch e.refType! {
            case .Repository:
                return e.repoDescription
            default:
                return nil
            }
        case .ForkEvent:
            let e = self as! ForkEvent
            return e.forkeeDescription
        case .GollumEvent:
            let e = self as! GollumEvent
            return e.summary
        case .IssueCommentEvent:
            let e = self as! IssueCommentEvent
            return e.comment!.body
        case .IssuesEvent:
            let e = self as! IssueEvent
            return e.issue!.title
        case .PublicEvent:
            let e = self as! PublicEvent
            return e.repositoryDescription
        case .PullRequestEvent:
            let e = self as! PullRequestEvent
            return e.pullRequest?.title
        case .PullRequestReviewCommentEvent:
            let e = self as! PullRequestReviewCommentEvent
            return e.comment!.body
        case .PushEvent:
            let e = self as! PushEvent
            var messages: [String] = []
            for commit in e.commits! {
                let sha = commit.sha!
                let shortenedSHA = sha.substringToIndex(sha.startIndex.advancedBy(7))
                let message = "\(shortenedSHA) \(commit.message!.componentsSeparatedByString("\n")[0])"
                messages.append(message)
            }
            return messages.joinWithSeparator("\n")
        default:
            return nil
        }
    }

}