//
//  Queries.swift
//  iGithub
//
//  Created by Chan Hocheung on 04/08/2017.
//  Copyright © 2017 Hocheung. All rights reserved.
//

import Foundation
import Mustache

func query(for fileName: String) -> String {
	let path = Bundle.main.url(forResource: fileName, withExtension: "graphql")
	
	return try! String(contentsOf: path!, encoding: String.Encoding.utf8)
}

let repositoryQuery: String = {
	return query(for: "Repository")
}()

fileprivate let repositoryNodeQuery: String = {
	return query(for: "RepositoryNode")
}()

let repositoriesTemplate: Template = {
	return try! Template(named: "Repositories.graphql")
}()

let userRepositoriesQuery: String = {
	
	let data = [
		"OrderType": "RepositoryOrder",
		"owner_type": "user",
		"connection": "repositories",
		"repositoryNode": repositoryNodeQuery,
	]
	return try! repositoriesTemplate.render(Box(data))
}()

let organizationRepositoriesQuery: String = {
	
	let data = [
		"OrderType": "RepositoryOrder",
		"owner_type": "organization",
		"connection": "repositories",
		"repositoryNode": repositoryNodeQuery,
	]
	return try! repositoriesTemplate.render(Box(data))
}()

let starredRepositoriesQuery: String = {
	
	let data = [
		"OrderType": "StarOrder",
		"owner_type": "user",
		"connection": "starredRepositories",
		"repositoryNode": repositoryNodeQuery,
	]
	return try! repositoriesTemplate.render(Box(data))
}()

let watchingQuery: String = {
	
	let data = [
		"OrderType": "RepositoryOrder",
		"owner_type": "user",
		"connection": "watching",
		"repositoryNode": repositoryNodeQuery,
	]
	return try! repositoriesTemplate.render(Box(data))
}()

let searchRepositoriesQuery: String = {
    let template = try! Template(named: "SearchRepositories.graphql")
    let data = [
        "repositoryNode": repositoryNodeQuery,
    ]
    
    return try! template.render(Box(data))
}()
