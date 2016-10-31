//
//  AccountManager.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import KeychainAccess
import Moya
import RxMoya
import RxSwift
import ObjectMapper

class AccountManager {
    
    static let keychain = Keychain(server: "https://github.com", protocolType: .https)
    
    static var disposeBag = DisposeBag()
    
    static var currentUser: User? = {
        if let json = keychain["user_json"] {
            return Mapper<User>().map(JSONString: json)
        }
        return nil
    }() {
        didSet {
            keychain["user_json"] = currentUser != nil ? Mapper().toJSONString(currentUser!, prettyPrint: true) : nil
        }
    }
    
    static var token: String? = keychain["access_token"] {
        didSet {
            keychain["access_token"] = token
        }
    }
    
    class func logout() {
        currentUser = nil
        token = nil
    }
    
    class func requestToken(_ code: String, success: @escaping () -> Void, failure: @escaping (Moya.Error) -> Void) {
        WebProvider
            .request(.accessToken(code: code))
            .mapString()
            .subscribe(
                onNext: {
                    guard let accessToken = $0.components(separatedBy: "&").first?.components(separatedBy: "=").last else {
                        return
                    }
                    AccountManager.token = accessToken
                    
                    GithubProvider
                        .request(.oAuthUser(accessToken: accessToken))
                        .mapJSON()
                        .subscribe(
                            onNext: {
                                AccountManager.currentUser = Mapper<User>().map(JSONObject: $0)
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
