//
//  iGithubUITests.swift
//  iGithubUITests
//
//  Created by AeternChan on 7/20/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import XCTest

class iGithubUITests: XCTestCase {
    
    let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSnapshot() {
        
        snapshot("0Launch")
        let tabBar = app.tabBars
        
        tabBar.buttons.element(boundBy: 1).tap()
        snapshot("1Explore")
        
        tabBar.buttons.element(boundBy: 2).tap()
        
        for i in [5, 2, 7] {
            let table = app.tables.element(boundBy: 0)
            table.cells.element(boundBy: i).tap()
        }
        
        snapshot("2Repositories")
        
        for i in [5, 0] {
            let table = app.tables.element(boundBy: 0)
            table.cells.element(boundBy: i).tap()
        }
        
        snapshot("3Issue")
    }
    
}
