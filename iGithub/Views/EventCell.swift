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
    @IBOutlet weak var titleLabel: TTTAttributedLabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    var entity: Event! {
        didSet {
            avatarView.setAvatarWithURL(entity.actor!.avatarURL)
            titleLabel.text = entity.title
            
            let icon = entity.icon
            iconLabel.text = icon.text
            iconLabel.textColor = icon.color
            timeLabel.text = entity.createdAt!.naturalString
            
            contentLabel.text = entity.content
            contentLabel.hidden = contentLabel.text == nil
            
            self.addLinks()
        }
    }
    
    func addLinks() {
        titleLabel.linkAttributes = [NSForegroundColorAttributeName: UIColor(netHex: 0x4078C0), NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleNone.rawValue]
        
        let rawTitle = titleLabel.text! as NSString
        
        if entity.actor != nil {
            self.addLink(NSURL(string: "https://github.com/\(entity.actor!)")!, toText: entity.actor!.login!, inTitle: rawTitle)
        }
        
        if entity.repository != nil {
            self.addLink(NSURL(string: "https://github.com/\(entity.repository!)")!, toText: entity.repository!, inTitle: rawTitle)
        }
        
        if entity.org != nil {
            self.addLink(NSURL(string: "https://github.com/\(entity.org!)")!, toText: entity.org!.login!, inTitle: rawTitle)
        }
        
        switch entity.type! {
        case .ForkEvent:
            let e = entity as! ForkEvent
            self.addLink(NSURL(string: "https://github.com/\(e.forkee!)")!, toText: e.forkee!, inTitle: rawTitle)
        case .IssueCommentEvent:
            let e = entity as! IssueCommentEvent
            self.addLink(NSURL(string: "https://github.com/\(e.repository!)/issues/\(e.issue!.number!)")!, toText: "#\(e.issue!.number!)", inTitle: rawTitle)
        case .IssuesEvent:
            let e = entity as! IssueEvent
            self.addLink(NSURL(string: "https://github.com/\(e.repository!)/issues/\(e.issue!.number!)")!, toText: "#\(e.issue!.number!)", inTitle: rawTitle)
        case .GollumEvent:
            let e = entity as! GollumEvent
            self.addLink(NSURL(string: "https://github.com/\(e.repository!)/wiki/\(e.pageName!)")!, toText: e.pageName!, inTitle: rawTitle)
        case .MemberEvent:
            let e = entity as! MemberEvent
            self.addLink(NSURL(string: "https://github.com/\(e.member!)")!, toText: e.member!.login!, inTitle: rawTitle)
        case .PullRequestEvent:
            let e = entity as! PullRequestEvent
            self.addLink(NSURL(string: "https://github.com/pull/\(e.pullRequest!.number!)")!, toText: "#\(e.pullRequest!.number!)", inTitle: rawTitle)
        case .PullRequestReviewCommentEvent:
            let e = entity as! PullRequestReviewCommentEvent
            self.addLink(NSURL(string: "https://github.com/pull/\(e.pullRequest!.number!)")!, toText: "#\(e.pullRequest!.number!)", inTitle: rawTitle)
        default:
            break
        }
        
    }
    
    func addLink(url: NSURL, toText text: String, inTitle title: NSString) {
        let regexString = NSString(format: "^%1$@\\s|\\s%1$@\\s|\\s%1$@$", text) as String
        let range = title.rangeOfString(regexString, options: .RegularExpressionSearch)
        titleLabel.addLinkToURL(url, withRange: range)
    }
}
