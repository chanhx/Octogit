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
    
    static let shareInstance = AccountManager()
    
    let keychain = Keychain(server: "https://github.com", protocolType: .https)
    
    lazy var disposeBag = DisposeBag()
    
    var currentUser: User? {
        didSet {
            keychain["user_json"] = currentUser != nil ? Mapper().toJSONString(currentUser!, prettyPrint: true) : nil
        }
    }
    var token: String? {
        didSet {
            keychain["access_token"] = token
        }
    }
    
    init() {
        token = keychain["access_token"]
        if let json = keychain["user_json"] {
            currentUser = Mapper<User>().map(JSONString: json)
        }
    }
    
    func requestToken(_ code: String, success: @escaping () -> Void, failure: @escaping (RxMoya.Error) -> Void) {
        WebProvider
            .request(.accessToken(code: code))
            .mapString()
            .subscribe(
                onNext: {
                    guard let accessToken = $0.components(separatedBy: "&").first?.components(separatedBy: "=").last else {
                        return
                    }
                    AccountManager.shareInstance.token = accessToken
                    
                    GithubProvider
                        .request(.oAuthUser(accessToken: accessToken))
                        .mapJSON()
                        .subscribe(
                            onNext: {
                                AccountManager.shareInstance.currentUser = Mapper<User>().map(JSONObject: $0)
                                success()
                            }//,
//                            onError: {
//                                failure($0)
//                            }
                        )
                        .addDisposableTo(self.disposeBag)
                }//,
//                onError: {
//                    failure($0)
//                }
            )
            .addDisposableTo(disposeBag)
    }
}
