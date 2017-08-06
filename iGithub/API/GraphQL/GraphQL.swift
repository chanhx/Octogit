//
//  GraphQL.swift
//  iGithub
//
//  Created by Chan Hocheung on 12/06/2017.
//  Copyright © 2017 Hocheung. All rights reserved.
//

import Foundation

class GraphQL {
	static func query(_ token: GitHubAPI) -> [String: Any]? {
		switch token {
        case .repository(let repo):
            return [
                "query": repositoryQuery,
                "variables": ["owner": repo.owner, "name": repo.name]
            ]

        case .repositories(let login, let type, let after):

            var variables: [String : Any] = [
                "login": login,
                "first": 30,
                "orderBy": ["field": "PUSHED_AT", "direction": "DESC"]
            ]
            if let after = after {
                variables["after"] = after
            }

            return [
                "query": type == .user ? userRepositoriesQuery : organizationRepositoriesQuery,
                "variables": variables
            ]

        case .starredRepos(let user, let after):

            var variables: [String : Any] = [
                "login": user,
                "first": 30,
                "orderBy": ["field": "STARRED_AT", "direction": "DESC"]
            ]
            if let after = after {
                variables["after"] = after
            }

            return [
                "query": starredRepositoriesQuery,
                "variables": variables
            ]
        
        case .subscribedRepos(let user, let after):
            var variables: [String : Any] = [
                "login": user,
                "first": 30,
                "orderBy": ["field": "UPDATED_AT", "direction": "DESC"]
            ]
            if let after = after {
                variables["after"] = after
            }

            return [
                "query": watchingQuery,
                "variables": variables
            ]
        default:
            return nil
		}
	}
}
