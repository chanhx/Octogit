//
//  SegmentViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/9/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import TwicketSegmentedControl
import Pageboy

class SegmentViewController: UIViewController {
    
    var titles: [String]
    var viewControllers: [UIViewController]
    let pageViewController = PageboyViewController()
    let segmentedControl = TwicketSegmentedControl()
    var initialPage: Int
    
    init(viewControllers: [UIViewController], titles: [String], initialPage: Int = 0) {
        
        assert(viewControllers.count == titles.count)
        
        self.titles = titles
        self.viewControllers = viewControllers
        segmentedControl.setSegmentItems(titles)

        self.initialPage = initialPage
        
        super.init(nibName: nil, bundle: nil)
        
        addChildViewController(pageViewController)
        pageViewController.didMove(toParentViewController: self)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        segmentedControl.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        configureSegmentedControl()
    }
    
    func configureSegmentedControl() {
        
        let contentView = pageViewController.view!
        
        let line = UIView()
        line.backgroundColor = UIColor(netHex: 0xB2B2B2)
        
        view.addSubviews([contentView, line, segmentedControl])
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            
            line.heightAnchor.constraint(equalToConstant: 1),
            line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            line.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            line.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor),
            
            segmentedControl.heightAnchor.constraint(equalToConstant: TwicketSegmentedControl.height),
            segmentedControl.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			segmentedControl.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

extension SegmentViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        pageViewController.scrollToPage(.at(index: segmentIndex), animated: true)
    }
}

extension SegmentViewController: PageboyViewControllerDataSource {
    
    public func numberOfViewControllers(in pageboyViewController: Pageboy.PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    public func viewController(for pageboyViewController: Pageboy.PageboyViewController, 
                               at index: Pageboy.PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    public func defaultPage(for pageboyViewController: Pageboy.PageboyViewController) -> Pageboy.PageboyViewController.Page? {
        
        return Pageboy.PageboyViewController.Page.at(index: initialPage)
    }
}

extension SegmentViewController: PageboyViewControllerDelegate {

    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didScrollToPageAt index: Int,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
        segmentedControl.move(to: index)
    }
}

