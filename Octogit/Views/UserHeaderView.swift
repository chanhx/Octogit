//
//  UserHeaderView.swift
//  Octogit
//
//  Created by Chan Hocheung on 16/07/2017.
//  Copyright © 2017 Hocheung. All rights reserved.
//

import UIKit

@objc protocol UserHeaderViewProtocol: class {
    
    @objc optional func didTapAvatarViwe()
    @objc optional func didTapRepositoiesButton()
    @objc optional func didTapFollowersButton()
    @objc optional func didTapFollowingButton()
}

class UserHeaderView: UIView {

    private let avatarView = UIImageView()
    private let nameLabel = UILabel()
    private let repositoriesButton = CountButton()
    private let followersButton = CountButton()
    private let followingButton = CountButton()
    
    var delegate: UserHeaderViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSubviews()
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureSubviews()
        setLayout()
    }
    
    private func configureSubviews() {
        
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        
        repositoriesButton.addTarget(delegate, action: #selector(UserHeaderViewProtocol.didTapRepositoiesButton), for: .touchUpInside)
        followersButton.addTarget(delegate, action: #selector(UserHeaderViewProtocol.didTapFollowersButton), for: .touchUpInside)
        followingButton.addTarget(delegate, action: #selector(UserHeaderViewProtocol.didTapFollowingButton), for: .touchUpInside)
    }
    
    private func setLayout() {
        
        let stackView = UIStackView(arrangedSubviews: [repositoriesButton, followersButton, followingButton])
        stackView.distribution = .equalSpacing
        
        addSubviews([avatarView, nameLabel, stackView])
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarView.topAnchor.constraint(equalTo: topAnchor),
            
            avatarView.widthAnchor.constraint(equalToConstant: 60),
            avatarView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func setContent(withUser user: User) {
        
        avatarView.setAvatar(with: user.avatarURL)
        nameLabel.text = user.name ?? user.login
        followersButton.setTitle(user.followers, title: "Followers")
        repositoriesButton.setTitle(user.publicRepos, title: "Repositories")
        followingButton.setTitle(user.following, title: "Following")
    }
}
