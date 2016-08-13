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
            return "\(e.actor!) commented on \(shortenedSHA) at \(e.repository!)"
        case .CreateEvent:
            let e = self as! CreateEvent
            switch e.refType! {
            case .Repository:
                return "\(e.actor!) created \(e.refType!.rawValue) \(e.repository!)"
            default:
                return "\(e.actor!) created \(e.refType!.rawValue) \(e.ref!) at \(e.repository!)"
            }
        case .DeleteEvent:
            let e = self as! DeleteEvent
            return "\(e.actor!) deleted \(e.refType?.rawValue) \(e.ref!) at \(e.repository!)"
        case .ForkEvent:
            let e = self as! ForkEvent
            return "\(e.actor!) forked \(e.repository!) to \(e.forkee!)"
        case .GollumEvent:
            let e = self as! GollumEvent
            return "\(e.actor!) \(e.action!) \(e.pageName!) in the \(e.repository!) wiki"
        case .IssueCommentEvent:
            let e = self as! IssueCommentEvent
            return "\(e.actor!) \(e.action!) comment on issue \(e.repository!)#\(e.issue!.number!)"
        case .IssuesEvent:
            let e = self as! IssueEvent
            return "\(e.actor!) \(e.action!) issue \(e.repository!)#\(e.issue!.number!)"
        case .MemberEvent:
            let e = self as! MemberEvent
            return "\(e.actor!) added \(e.member!) to \(e.repository!)"
        case .PublicEvent:
            return "\(self.actor!) open-sourced \(self.repository!)"
        case .PullRequestEvent:
            let e = self as! PullRequestEvent
            var action: String
            if e.action! == .Closed && e.pullRequest!.isMerged! {
                action = "merged"
            } else {
                action = e.action!.rawValue
            }
            return "\(e.actor!) \(action) pull request \(e.repository!)#\(e.pullRequest!.number!)"
        case .PullRequestReviewCommentEvent:
            let e = self as! PullRequestReviewCommentEvent
            return "\(e.actor!) \(e.action) comment on issue \(e.repository!)#\(e.pullRequest!.number!)"
        case .PushEvent:
            let e = self as! PushEvent
            return "\(e.actor!) pushed to \(e.ref!) at \(e.repository!)"
        case .ReleaseEvent:
            let e = self as! ReleaseEvent
            return "\(e.actor) released \(e.releaseTagName) at \(e.repository)"
        case .WatchEvent:
            return "\(self.actor!) starred \(self.repository!)"
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
    
    var icon: (text: String, color: UIColor) {
        
        var icon: Octicon?
        var color = UIColor.darkGrayColor()
        
        switch type! {
        case .CommitCommentEvent, .PullRequestReviewCommentEvent, .IssueCommentEvent:
            icon = Octicon.Comment
        case .CreateEvent:
            let e = self as! CreateEvent
            switch e.refType! {
            case .Branch:
                icon = Octicon.GitBranch
            case .Repository:
                icon = Octicon.Repo
            case .Tag:
                icon = Octicon.Tag
            }
        case .DeleteEvent:
            icon = Octicon.DiffRemoved
        case .ForkEvent:
            icon = Octicon.RepoForked
        case .GollumEvent:
            icon = Octicon.Book
        case .IssuesEvent:
            let e = self as! IssueEvent
            switch e.action! {
            case .Closed:
                icon = Octicon.IssueClosed
                color = UIColor(netHex: 0xBD2C00)
            default:
                icon = Octicon.IssueOpened
                color = UIColor(netHex: 0x6CB644)
            }
        case .MemberEvent:
            icon = Octicon.Organization
        case .PublicEvent:
            icon = Octicon.Repo
        case .PullRequestEvent:
            let e = self as! PullRequestEvent
            icon = Octicon.GitPullRequest
            if e.action! == .Closed && e.pullRequest!.isMerged! {
                color = UIColor(netHex: 0x6E5494)
            } else if e.action! == .Closed {
                color = UIColor(netHex: 0xBD2C00)
            } else {
                color = UIColor(netHex: 0x6BB644)
            }
        case .PushEvent:
            icon = Octicon.GitCommit
        case .ReleaseEvent:
            icon = Octicon.Tag
        case .WatchEvent:
            icon = Octicon.Star
            color = UIColor(netHex: 0xFFBF03)
        default:
            break
        }
        
        return (icon?.rawValue ?? "", color)
    }

}