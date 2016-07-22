//
//  EventCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftDate

class EventCell: UITableViewCell {

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceFromDetail: NSLayoutConstraint!
    
    var entity: Event! {
        didSet {
            avatarView.kf_setImageWithURL(entity.actor!.avatarURL, placeholderImage: UIImage(named: "default-avatar"))
            timeLabel.text = entity.createdAt!.toNaturalString(NSDate(), style: FormatterStyle(style: .Full, max: 1))! + " ago"
            
            titleLabel.text = eventTitle(entity)
            
            detailLabel.text = nil
            distanceFromDetail.constant = 0
        }
    }
    
}

func eventTitle(event: Event) -> String {
    
    switch event.type! {
    case .CommitCommentEvent:
        let e = event as! CommitCommentEvent
        return "\(e.actor!) commented on \(e.comment!.commitID!) at \(e.repositoryName!)"
    case .CreateEvent:
        let e = event as! CreateEvent
        switch e.refType! {
        case .Repository:
            return "\(e.actor!) created \(e.refType!.rawValue) \(e.repositoryName!)"
        default:
            return "\(e.actor!) created \(e.refType!.rawValue) \(e.ref!) at \(e.repositoryName!)"
        }
    case .DeleteEvent:
        let e = event as! DeleteEvent
        return "\(e.actor!) deleted \(e.refType?.rawValue) \(e.ref!) at \(e.repositoryName!)"
    case .ForkEvent:
        let e = event as! ForkEvent
        return "\(e.actor!) forked \(e.repositoryName!) to \(e.forkeeFullName!)"
    case .GollumEvent:
        let e = event as! GollumEvent
        return "\(e.actor!) \(e.action!) \(e.pageName) in the \(e.repositoryName!) wiki"
    case .IssueCommentEvent:
        let e = event as! IssueCommentEvent
        return "\(e.actor!) \(e.action) comment on issue \(e.repositoryName!)#\(e.issue!.id!)"
    case .IssuesEvent:
        let e = event as! IssueEvent
        return "\(e.actor!) \(e.action!) issue \(e.repositoryName!)#\(e.issue!.id!)"
    case .MemberEvent:
        let e = event as! MemberEvent
        return "\(e.actor!) added \(e.member!) to \(e.repositoryName!)"
    case .PublicEvent:
        return "\(event.actor!) open-sourced \(event.repositoryName!)"
    case .PullRequestEvent:
        let e = event as! PullRequestEvent
        var action: String
        if e.action! == .Closed && e.pullRequest!.isMerged! {
            action = "merged"
        } else {
            action = e.action!.rawValue
        }
        return "\(e.actor!) \(action) pull request \(e.repositoryName!)#\(e.pullRequest!.id!)"
    case .PullRequestReviewCommentEvent:
        let e = event as! PullRequestReviewCommentEvent
        return "\(e.actor!) \(e.action) comment on issue \(e.repositoryName!)#\(e.pullRequest!.id!)"
    case .PushEvent:
        let e = event as! PushEvent
        return "\(e.actor!) pushed to \(e.ref!) at \(e.repositoryName!)"
    case .ReleaseEvent:
        let e = event as! ReleaseEvent
        return "\(e.actor) released \(e.releaseTagName) at \(e.repositoryName)"
    case .WatchEvent:
        return "\(event.actor!) starred \(event.repositoryName!)"
    default:
        return ""
    }
}
