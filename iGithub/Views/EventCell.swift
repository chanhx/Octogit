//
//  EventCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import SwiftDate
import TTTAttributedLabel

class EventCell: UITableViewCell {

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: TTTAttributedLabel! {
        didSet {
            titleLabel.linkAttributes = [
                NSForegroundColorAttributeName: UIColor(netHex: 0x4078C0),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleNone.rawValue
            ]
        }
    }
    @IBOutlet weak var contentLabel: TTTAttributedLabel! {
        didSet {
            contentLabel.linkAttributes = [
                NSForegroundColorAttributeName: UIColor(netHex: 0x4078C0),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleNone.rawValue
            ]
        }
    }
    
    var entity: Event! {
        didSet {
            avatarView.setAvatarWithURL(entity.actor!.avatarURL)
            titleLabel.text = entity.title
            
            let icon = entity.icon
            iconLabel.text = icon.text
            iconLabel.textColor = icon.color
            timeLabel.text = entity.createdAt!.naturalString
            
            contentLabel.text = entity.content
            contentLabel.isHidden = contentLabel.text == nil
            
            addLinksToTitle()
            addLinksToContent()
        }
    }
    
    func addLinksToTitle() {
        if entity.actor != nil {
            titleLabel.addLink(URL(string: "/\(entity.actor!)")!, toText: entity.actor!.login!)
        }
        
        if entity.repository != nil {
            titleLabel.addLink(URL(string: "/\(entity.repository!)")!, toText: entity.repository!)
        }
        
        if entity.org != nil {
            titleLabel.addLink(URL(string: "/\(entity.org!)")!, toText: entity.org!.login!)
        }
        
        switch entity.type! {
        case .forkEvent:
            let e = entity as! ForkEvent
            titleLabel.addLink(URL(string: "/\(e.forkee!)")!, toText: e.forkee!)
        case .issueCommentEvent:
            let e = entity as! IssueCommentEvent
            titleLabel.addLink(URL(string: "/\(e.repository!)/issues/\(e.issue!.number!)")!, toText: "\(e.repository!)#\(e.issue!.number!)")
        case .issuesEvent:
            let e = entity as! IssueEvent
            titleLabel.addLink(URL(string: "/\(e.repository!)/issues/\(e.issue!.number!)")!, toText: "\(e.repository!)#\(e.issue!.number!)")
        case .gollumEvent:
            let e = entity as! GollumEvent
            titleLabel.addLink(URL(string: "/\(e.repository!)/wiki/\(e.pageName!)")!, toText: e.pageName!)
        case .memberEvent:
            let e = entity as! MemberEvent
            titleLabel.addLink(URL(string: "/\(e.member!)")!, toText: e.member!.login!)
        case .pullRequestEvent:
            let e = entity as! PullRequestEvent
            titleLabel.addLink(URL(string: "/pull/\(e.pullRequest!.number!)")!, toText: "#\(e.pullRequest!.number!)")
        case .pullRequestReviewCommentEvent:
            let e = entity as! PullRequestReviewCommentEvent
            titleLabel.addLink(URL(string: "/pull/\(e.pullRequest!.number!)")!, toText: "#\(e.pullRequest!.number!)")
        default:
            break
        }
        
    }
    
    func addLinksToContent() {
        if entity.type! == .pushEvent {
            let e = entity as! PushEvent
            for commit in e.commits! {
                let sha = commit.sha!
                let shortenedSHA = sha.substring(to: sha.characters.index(sha.startIndex, offsetBy: 7))
                contentLabel.addLink(URL(string: "/\(entity.repository!)/commit/\(sha)")!, toText: shortenedSHA)
            }
        }
    }
}
