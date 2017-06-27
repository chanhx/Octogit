//
//  GraphQL.swift
//  iGithub
//
//  Created by Chan Hocheung on 12/06/2017.
//  Copyright © 2017 Hocheung. All rights reserved.
//

import Foundation

class GraphQL {
    static func query(_ token: GitHubAPI) -> String {
        switch token {
        case .repository(let repo):
            let components = repo.components(separatedBy: "/")
            let owner = components[0]
            let repo = components[1]
            
            return "{  repository(owner: \"\(owner)\", name: \"\(repo)\") {    owner {      login      avatarUrl      __typename    }    name    homepageUrl    isFork    isPrivate    isMirror    hasWikiEnabled    pushedAt    viewerHasStarred    hasIssuesEnabled    diskUsage    description    defaultBranchRef {      id      name    }    primaryLanguage {      name    }    issues(states: [OPEN]) {      totalCount    }    stargazers {      totalCount    }    forks {      totalCount    }    watchers {      totalCount    }    pullRequests(states: [OPEN]) {      totalCount    }    releases {      totalCount    }    parent {      name      owner {        login      }    }  }}"
        default:
            return ""
        }
    }
}
