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
        default:
            return nil
        }
    }
}

let repositoryQuery = "query($owner:String!, $name:String!) {  repository(owner: $owner, name: $name) {    owner {      login      avatar_url: avatarUrl      type: __typename    }    name    nameWithOwner    homepageUrl    isFork    isPrivate    isMirror    hasWikiEnabled    pushedAt    viewerHasStarred    hasIssuesEnabled    diskUsage    description    defaultBranchRef {      id      name    }    primaryLanguage {      name      color    }    issues(states: [OPEN]) {      totalCount    }    stargazers {      totalCount    }    forks {      totalCount    }    watchers {      totalCount    }    pullRequests(states: [OPEN]) {      totalCount    }    releases {      totalCount    }    parent {      name      owner {        login      }    }  }}"
