//
//  SegmentViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/9/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import TwicketSegmentedControl

class SegmentViewController: UIViewController {
    
    var titles: [String]
    
    init(viewControllers: [UIViewController], titles: [String]) {
        
        assert(viewControllers.count == titles.count)
        
        self.titles = titles
        
        super.init(nibName: nil, bundle: nil)
        
        viewControllers.forEach {
            addChildViewController($0)
            $0.didMove(toParentViewController: self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addView(ofViewController: childViewControllers[0])
        
        configureSegmentedControl()
    }
    
    func configureSegmentedControl() {
        let segmentedControl = TwicketSegmentedControl()
        let height = TwicketSegmentedControl.height
        
        segmentedControl.frame = CGRect(x: 0,
                                        y: view.bounds.height - height,
                                        width: view.bounds.width,
                                        height: height)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: view.bounds.height - 41, width: view.bounds.width, height: 41))
        let segmentedControlItem = UIBarButtonItem(customView: segmentedControl)
        let fixSpace0 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        
        fixSpace0.width = -16
        
        toolbar.setItems([fixSpace0, segmentedControlItem, fixSpace0], animated: false)
        
        segmentedControl.setSegmentItems(titles)
        segmentedControl.delegate = self
        
        view.addSubview(toolbar)
    }
    
    func addView(ofViewController vc: UIViewController) {
        var frame = view.bounds
        frame.size.height -= TwicketSegmentedControl.height
        vc.view.frame = frame
        view.addSubview(vc.view)
        view.sendSubview(toBack: vc.view)
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // important! cause scrollview insets to be re-calculated for the new view controller's contents
        // http://stackoverflow.com/a/33344516/2596280
        navigationController?.view.setNeedsLayout()
    }
}

extension SegmentViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        for (index, vc) in childViewControllers.enumerated() {
            if index == segmentIndex {
                addView(ofViewController: vc)
            } else {
                vc.view.removeFromSuperview()
            }
        }
    }
}
