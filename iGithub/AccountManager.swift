//
//  AccountManager.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import KeychainAccess
import RxMoya
import RxSwift
import ObjectMapper

class AccountManager {
    
    static let shareManager = AccountManager()
    
    lazy var keychain = Keychain(server: "https://github.com", protocolType: .HTTPS)
    lazy var oauthProvider = RxMoyaProvider<OAuthAPI>()
    lazy var githubProvider = RxMoyaProvider<GithubAPI>()
    lazy var disposeBag = DisposeBag()
    
    var currentUser: User? {
        didSet {
            keychain["userJSON"] = currentUser != nil ? Mapper().toJSONString(currentUser!, prettyPrint: true) : nil
        }
    }
    var token: String? {
        didSet {
            keychain["access_token"] = token
        }
    }
    
    init() {
        token = keychain["access_token"]
        currentUser = Mapper<User>().map(keychain["userJSON"])
    }
    
    func requestToken(code: String, success: () -> Void, failure: ErrorType -> Void) {
        oauthProvider
            .request(.AccessToken(code: code))
            .mapString()
            .subscribe(
                onNext: {
                    if let accessToken = $0.componentsSeparatedByString("&").first?.componentsSeparatedByString("=").last {
                        AccountManager.shareManager.token = accessToken
                        
                        self.githubProvider
                            .request(.OAuthUser(accessToken: accessToken))
                            .mapJSON()
                            .subscribe(
                                onNext: {
                                    AccountManager.shareManager.currentUser = Mapper<User>().map($0)
                                    success()
                                },
                                onError: {
                                    failure($0)
                                })
                            .addDisposableTo(self.disposeBag)
                    }
                },
                onError: {
                    failure($0)
                }
            )
            .addDisposableTo(disposeBag)
    }
}