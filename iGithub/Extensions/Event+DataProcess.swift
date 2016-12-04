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
        case .commitCommentEvent:
            let e = self as! CommitCommentEvent
            let commitID = e.comment!.commitID!
            let shortSHA = commitID.substring(to: commitID.characters.index(commitID.startIndex, offsetBy: 7))
            return "\(e.actor!) commented on \(shortSHA) at \(e.repository!)"
        case .createEvent:
            let e = self as! CreateEvent
            switch e.refType! {
            case .repository:
                return "\(e.actor!) created \(e.refType!) \(e.repository!)"
            default:
                return "\(e.actor!) created \(e.refType!) \(e.ref!) at \(e.repository!)"
            }
        case .deleteEvent:
            let e = self as! DeleteEvent
            return "\(e.actor!) deleted \(e.refType!) \(e.ref!) at \(e.repository!)"
        case .forkEvent:
            let e = self as! ForkEvent
            return "\(e.actor!) forked \(e.repository!) to \(e.forkee!)"
        case .gollumEvent:
            let e = self as! GollumEvent
            return "\(e.actor!) \(e.action!) \(e.pageName!) in the \(e.repository!) wiki"
        case .issueCommentEvent:
            let e = self as! IssueCommentEvent
            let object = e.issue!.isPullRequest ? "pull request" : "issue"
            return "\(e.actor!) \(e.action!) comment on \(object) \(e.repository!)#\(e.issue!.number!)"
        case .issuesEvent:
            let e = self as! IssueEvent
            return "\(e.actor!) \(e.action!) issue \(e.repository!)#\(e.issue!.number!)"
        case .memberEvent:
            let e = self as! MemberEvent
            return "\(e.actor!) added \(e.member!) to \(e.repository!)"
        case .publicEvent:
            return "\(self.actor!) made \(self.repository!) public"
        case .pullRequestEvent:
            let e = self as! PullRequestEvent
            var action: String
            if e.action! == .closed && e.pullRequest!.isMerged! {
                action = "merged"
            } else {
                action = e.action!.rawValue
            }
            return "\(e.actor!) \(action) pull request \(e.repository!)#\(e.pullRequest!.number!)"
        case .pullRequestReviewCommentEvent:
            let e = self as! PullRequestReviewCommentEvent
            return "\(e.actor!) \(e.action!) comment on pull request \(e.repository!)#\(e.pullRequest!.number!)"
        case .pushEvent:
            let e = self as! PushEvent
            let ref = e.ref!.removePrefix("refs/heads/")
            
            return "\(e.actor!) pushed to \(ref) at \(e.repository!)"
        case .releaseEvent:
            let e = self as! ReleaseEvent
            return "\(e.actor!) released \(e.releaseTagName!) at \(e.repository!)"
        case .watchEvent:
            return "\(self.actor!) starred \(self.repository!)"
        default:
            return ""
        }
    }
    
    var content: String? {
        switch self.type! {
        case .commitCommentEvent:
            let e = self as! CommitCommentEvent
            return e.comment!.body!
        case .createEvent:
            let e = self as! CreateEvent
            switch e.refType! {
            case .repository:
                return e.repoDescription
            default:
                return nil
            }
        case .forkEvent:
            let e = self as! ForkEvent
            return e.forkeeDescription
        case .gollumEvent:
            let e = self as! GollumEvent
            return e.summary
        case .issueCommentEvent:
            let e = self as! IssueCommentEvent
            return e.comment!
        case .issuesEvent:
            let e = self as! IssueEvent
            return e.issue!.title
        case .publicEvent:
            let e = self as! PublicEvent
            return e.repositoryDescription
        case .pullRequestEvent:
            let e = self as! PullRequestEvent
            return e.pullRequest?.title
        case .pullRequestReviewCommentEvent:
            let e = self as! PullRequestReviewCommentEvent
            return e.comment!
        case .pushEvent:
            let e = self as! PushEvent
            var messages: [String] = []
            for commit in e.commits! {
                let sha = commit.sha!
                let shortSHA = sha.substring(to: sha.characters.index(sha.startIndex, offsetBy: 7))
                let message = "\(shortSHA) \(commit.message!.components(separatedBy: "\n")[0])"
                messages.append(message)
            }
            return messages.joined(separator: "\n")
        default:
            return nil
        }
    }
    
    var icon: (text: String, color: UIColor) {
        
        var icon: Octicon?
        var color = UIColor.darkGray
        
        switch type! {
        case .commitCommentEvent, .pullRequestReviewCommentEvent, .issueCommentEvent:
            icon = Octicon.comment
        case .createEvent:
            let e = self as! CreateEvent
            switch e.refType! {
            case .branch:
                icon = Octicon.gitBranch
            case .repository:
                icon = Octicon.repo
            case .tag:
                icon = Octicon.tag
            }
        case .deleteEvent:
            icon = Octicon.diffRemoved
        case .forkEvent:
            icon = Octicon.repoForked
        case .gollumEvent:
            icon = Octicon.book
        case .issuesEvent:
            let e = self as! IssueEvent
            switch e.action! {
            case .closed:
                icon = Octicon.issueClosed
                color = UIColor(netHex: 0xBD2C00)
            default:
                icon = Octicon.issueOpened
                color = UIColor(netHex: 0x6CB644)
            }
        case .memberEvent:
            icon = Octicon.organization
        case .publicEvent:
            icon = Octicon.repo
        case .pullRequestEvent:
            let e = self as! PullRequestEvent
            icon = Octicon.gitPullrequest
            if e.action! == .closed && e.pullRequest!.isMerged! {
                color = UIColor(netHex: 0x6E5494)
            } else if e.action! == .closed {
                color = UIColor(netHex: 0xBD2C00)
            } else {
                color = UIColor(netHex: 0x6BB644)
            }
        case .pushEvent:
            icon = Octicon.gitCommit
        case .releaseEvent:
            icon = Octicon.tag
        case .watchEvent:
            icon = Octicon.star
            color = UIColor(netHex: 0xFFBF03)
        default:
            break
        }
        
        return (icon?.rawValue ?? "", color)
    }

}
