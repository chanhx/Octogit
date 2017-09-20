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

    let avatarView = UIImageView()
    let iconLabel = UILabel()
    let timeLabel = UILabel()
    let titleLabel = TTTAttributedLabel(frame: .zero)
    let contentLabel = TTTAttributedLabel(frame: .zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.configureSubviews()
        self.layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        iconLabel.font = UIFont.OcticonOfSize(15)
        timeLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        
        iconLabel.textColor = UIColor(netHex: 0x555555)
        timeLabel.textColor = UIColor(netHex: 0x888888)
        titleLabel.textColor = UIColor(netHex: 0x333333)
        contentLabel.textColor = UIColor(netHex: 0x666666)
        
        avatarView.isUserInteractionEnabled = true
        iconLabel.textAlignment = .right
        titleLabel.numberOfLines = 0
        contentLabel.numberOfLines = 0
        
        titleLabel.linkAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor(netHex: 0x4078C0),
            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleNone.rawValue
        ]
        contentLabel.linkAttributes = titleLabel.linkAttributes
        
        for label in [iconLabel, timeLabel, titleLabel, contentLabel] {
            label.layer.isOpaque = true
            label.layer.masksToBounds = true
            label.backgroundColor = .white
        }
    }
    
    func layout() {
        let hStackView1 = UIStackView(arrangedSubviews: [iconLabel, timeLabel])
        hStackView1.axis = .horizontal
        hStackView1.alignment = .center
        hStackView1.distribution = .fill
        hStackView1.spacing = 8
        
        let hStackView2 = UIStackView(arrangedSubviews: [avatarView, titleLabel])
        hStackView2.axis = .horizontal
        hStackView2.alignment = .center
        hStackView2.distribution = .fill
        hStackView2.spacing = 8
        
        let vStackView = UIStackView(arrangedSubviews: [hStackView1, hStackView2, contentLabel])
        vStackView.axis = .vertical
        vStackView.alignment = .fill
        vStackView.distribution = .fill
        vStackView.spacing = 8
        
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(vStackView)
        
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            hStackView1.heightAnchor.constraint(equalToConstant: 18),
            
            iconLabel.widthAnchor.constraint(equalToConstant: 36),
            
            avatarView.heightAnchor.constraint(equalToConstant: 36),
            avatarView.widthAnchor.constraint(equalToConstant: 36),
            
            vStackView.topAnchor.constraint(equalTo: margins.topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            vStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            vStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
    
    func configure(withEvent event: Event) {
        avatarView.setAvatar(with: event.actor!.avatarURL)
        titleLabel.text = event.title
        
        let icon = event.icon
        iconLabel.text = icon.text
        iconLabel.textColor = icon.color
        timeLabel.text = event.createdAt!.naturalString()
        
        contentLabel.text = event.content
        contentLabel.isHidden = contentLabel.text == nil
        contentLabel.numberOfLines = event.type! == .pushEvent ? 0 : 5
        
        addLinksToTitle(withEvent: event)
        addLinksToContent(withEvent: event)
    }
    
    func addLinksToTitle(withEvent event: Event) {
        
        if let actor = event.actor {
            titleLabel.addLink(URL(string: "/\(actor)")!, toText: actor.login!)
        }
        
        if let org = event.org {
            titleLabel.addLink(URL(string: "/\(org)")!, toText: org.login!)
        }
        
        if let repo = event.repository {
            titleLabel.addLink(URL(string: "/\(repo)")!, toText: repo)
        }
        
        switch event.type! {
        case .createEvent:
            let e = event as! CreateEvent
            if e.refType! != .repository {
                titleLabel.addLink(URL(string: "/\(e.repository!)/tree/\(e.ref!)")!, toText: e.ref!)
            }
        case .forkEvent:
            let e = event as! ForkEvent
            titleLabel.addLink(URL(string: "/\(e.forkee!)")!, toText: e.forkee!)
        case .issueCommentEvent:
            let e = event as! IssueCommentEvent
            let type = e.issue!.isPullRequest ? "pull" : "issues"
            titleLabel.addLink(URL(string: "/\(e.repository!)/\(type)/\(e.issue!.number!)")!, toText: "\(e.repository!)#\(e.issue!.number!)")
        case .issuesEvent:
            let e = event as! IssueEvent
            titleLabel.addLink(URL(string: "/\(e.repository!)/issues/\(e.issue!.number!)")!, toText: "\(e.repository!)#\(e.issue!.number!)")
        case .gollumEvent:
            let e = event as! GollumEvent
            titleLabel.addLink(URL(string: "/\(e.repository!)/wiki/\(e.pageName!)")!, toText: e.pageName!)
        case .memberEvent:
            let e = event as! MemberEvent
            titleLabel.addLink(URL(string: "/\(e.member!)")!, toText: e.member!.login!)
        case .pullRequestEvent:
            let e = event as! PullRequestEvent
            titleLabel.addLink(URL(string: "/\(e.repository!)/pull/\(e.pullRequest!.number!)")!, toText: "\(e.repository!)#\(e.pullRequest!.number!)")
        case .pullRequestReviewCommentEvent:
            let e = event as! PullRequestReviewCommentEvent
            titleLabel.addLink(URL(string: "/\(e.repository!)/pull/\(e.pullRequest!.number!)")!, toText: "\(e.repository!)#\(e.pullRequest!.number!)")
        case .pushEvent:
            let e = event as! PushEvent
            let ref = e.ref!.removePrefix("refs/heads/")
            
            titleLabel.addLink(URL(string: "/\(e.repository!)/tree/\(ref)")!, toText: ref)
        case .releaseEvent:
            let e = event as! ReleaseEvent
            titleLabel.addLink(URL(string: "/\(e.repository!)/tree/\(e.releaseTagName!)")!, toText: e.releaseTagName!)
        default:
            break
        }
    }
    
    func addLinksToContent(withEvent event: Event) {
        
        guard let e = event as? PushEvent else {
            return
        }
        
        for commit in e.commits! {
            contentLabel.addLink(URL(string: "/\(event.repository!)/commit/\(commit.sha!)")!, toText:  commit.shortSHA)
        }
    }
}
