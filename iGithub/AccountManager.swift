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
        guard let json = UserDefaults.standard.object(forKey: "user_json") as? String else {
            return nil
        }
        return Mapper<User>().map(JSONString: json)
    }() {
        didSet {
            let json = currentUser != nil ? Mapper().toJSONString(currentUser!, prettyPrint: true) : nil
            UserDefaults.standard.set(json, forKey: "user_json")
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
    
    class func refresh(completionHandler: @escaping (User) -> Void) {
        GitHubProvider
            .request(.user(user: AccountManager.currentUser!.login!))
            .mapJSON()
            .subscribe(onNext: {
                currentUser = Mapper<User>().map(JSONObject: $0)!
                completionHandler(currentUser!)
            })
            .addDisposableTo(disposeBag)
    }
    
    class func requestToken(_ code: String, success: @escaping () -> Void, failure: @escaping (MoyaError) -> Void) {
        GitHubProvider
            .request(.accessToken(code: code))
            .filterSuccessfulStatusAndRedirectCodes()
            .flatMapLatest { (response) -> Observable<Moya.Response> in
                
                guard let string = String(data: response.data, encoding: .utf8),
                    let accessToken = string.components(separatedBy: "&").first?.components(separatedBy: "=").last
                else {
                    throw MoyaError.stringMapping(response)
                }
                
                AccountManager.token = accessToken
                
                return GitHubProvider.request(.oAuthUser(accessToken: accessToken))
            }
            .filterSuccessfulStatusAndRedirectCodes()
            .mapJSON()
            .subscribe(
                onNext: {
                    AccountManager.currentUser = Mapper<User>().map(JSONObject: $0)
                    success()
                }
//                },
//                onError: {
//                    failure($0)
//                }
            )
            .addDisposableTo(disposeBag)
    }
}
