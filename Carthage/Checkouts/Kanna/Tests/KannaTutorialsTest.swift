//
//  KannaTutorialsTest.swift
//  Kanna
//
//  Created by Atsushi Kiwaki on 6/27/16.
//  Copyright © 2016 tid. All rights reserved.
//
import XCTest
@testable import Kanna

class KannaTutorialsTests: XCTestCase {
    func testParsingFromString() {
        let html = "<html><body><h1>Tutorials</h1></body></html>"
        if let htmlDoc = HTML(html: html, encoding: NSUTF8StringEncoding) {
            XCTAssert(htmlDoc.toHTML != nil)
        }

        let xml = "<root><item><name>Tutorials</name></item></root>"
        if let xmlDoc = XML(xml: xml, encoding: NSUTF8StringEncoding) {
            XCTAssert(xmlDoc.toXML != nil)
        }

    }

    func testParsingFromFile() {
        let filename = "test_HTML4"
        guard let filePath = NSBundle(forClass:self.classForCoder).pathForResource(filename, ofType:"html") else {
            return
        }
        let data = NSData(contentsOfFile: filePath)!
        if let doc = HTML(html: data, encoding: NSUTF8StringEncoding) {
            XCTAssert(doc.toHTML != nil)
        }

        let html = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        if let doc = HTML(html: html, encoding: NSUTF8StringEncoding) {
            XCTAssert(doc.toHTML != nil)
        }
    }

    func testParsingFromInternets() {
        let url = NSURL(string: "https://en.wikipedia.org/wiki/Cat")
        if let doc = HTML(url: url!, encoding: NSUTF8StringEncoding) {
            XCTAssert(doc.toHTML != nil)
        }
    }

    func testParsingFromEncoding() {
        let html = "<html><body><h1>Tutorials</h1></body></html>"
        if let htmlDoc = HTML(html: html, encoding: NSJapaneseEUCStringEncoding) {
            XCTAssert(htmlDoc.toHTML != nil)
        }
    }

    func testParsingOptions() {
        let html = "<html><body><h1>Tutorials</h1></body></html>"
        if let doc = HTML(html: html, encoding: NSUTF8StringEncoding, option: .HtmlParseUseLibxml([.STRICT])) {
            XCTAssert(doc.toHTML != nil)
        }
    }

    func testSearchingBasicSearching() {
        let TestVersionData = [
            "iOS 10",
            "iOS 9",
            "iOS 8",
            "macOS 10.12",
            "macOS 10.11",
            "tvOS 10.0",
        ]

        let TestVersionDataIOS = [
            "iOS 10",
            "iOS 9",
            "iOS 8",
        ]
        let filename = "versions"
        guard let filePath = NSBundle(forClass:self.classForCoder).pathForResource(filename, ofType:"xml") else {
            return
        }
        let xml = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        if let doc = XML(xml: xml, encoding: NSUTF8StringEncoding) {
            for (i, node) in doc.xpath("//name").enumerate() {
                XCTAssert(node.text! == TestVersionData[i])
            }

            let nodes = doc.xpath("//name")
            XCTAssert(nodes[0].text! == TestVersionData[0])


            for (i, node) in doc.xpath("//ios//name").enumerate() {
                XCTAssert(node.text! == TestVersionDataIOS[i])
            }

            for (i, node) in doc.css("ios name").enumerate() {
                XCTAssert(node.text! == TestVersionDataIOS[i])
            }

            XCTAssert(doc.css("tvos name").first!.text == "tvOS 10.0")
            XCTAssert(doc.at_css("tvos name")!.text == "tvOS 10.0")
        }
    }

    func testSearchingNamespaces() {
        let TestLibrariesDataGitHub = [
            "Kanna",
            "Alamofire",
        ]

        let TestLibrariesDataBitbucket = [
            "Hoge",
        ]

        let filename = "libraries"
        guard let filePath = NSBundle(forClass:self.classForCoder).pathForResource(filename, ofType:"xml") else {
            return
        }

        let xml = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        if let doc = XML(xml: xml, encoding: NSUTF8StringEncoding) {
            for (i, node) in doc.xpath("//github:title", namespaces: ["github": "https://github.com/"]).enumerate() {
                XCTAssert(node.text! == TestLibrariesDataGitHub[i])
            }
        }

        if let doc = XML(xml: xml, encoding: NSUTF8StringEncoding) {
            for (i, node) in doc.xpath("//bitbucket:title", namespaces: ["bitbucket": "https://bitbucket.org/"]).enumerate() {
                XCTAssert(node.text! == TestLibrariesDataBitbucket[i])
            }
        }
    }

    func testModifyingChangingTextContents() {
        let TestModifyHTML = "<body>\n    <h1>Snap, Crackle &amp; Pop</h1>\n    <div>A love triangle.</div>\n</body>"
        let filename = "sample"
        guard let filePath = NSBundle(forClass:self.classForCoder).pathForResource(filename, ofType:"html") else {
            return
        }
        let html = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        guard let doc = HTML(html: html, encoding: NSUTF8StringEncoding) else {
            return
        }

        var h1 = doc.at_css("h1")!
        h1.content = "Snap, Crackle & Pop"

        XCTAssert(doc.body?.toHTML == TestModifyHTML)
    }

    func testModifyingMovingNode() {
        let TestModifyHTML = "<body>\n    \n    <div>A love triangle.<h1>Three\'s Company</h1>\n</div>\n</body>"
        let TestModifyArrangeHTML = "<body>\n    \n    <div>A love triangle.</div>\n<h1>Three\'s Company</h1>\n</body>"
        let filename = "sample"
        guard let filePath = NSBundle(forClass:self.classForCoder).pathForResource(filename, ofType:"html") else {
            return
        }
        let html = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        guard let doc = HTML(html: html, encoding: NSUTF8StringEncoding) else {
            return
        }
        var h1  = doc.at_css("h1")!
        let div = doc.at_css("div")!

        h1.parent = div

        XCTAssert(doc.body!.toHTML == TestModifyHTML)

        div.addNextSibling(h1)

        XCTAssert(doc.body!.toHTML == TestModifyArrangeHTML)
    }

    func testModifyingNodesAndAttributes() {
        let TestModifyHTML = "<body>\n    <h2 class=\"show-title\">Three\'s Company</h2>\n    <div>A love triangle.</div>\n</body>"
        let filename = "sample"
        guard let filePath = NSBundle(forClass:self.classForCoder).pathForResource(filename, ofType:"html") else {
            return
        }
        let html = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        guard let doc = HTML(html: html, encoding: NSUTF8StringEncoding) else {
            return
        }
        var h1  = doc.at_css("h1")!

        h1.tagName = "h2"
        h1["class"] = "show-title"

        XCTAssert(doc.body?.toHTML == TestModifyHTML)
    }
}
