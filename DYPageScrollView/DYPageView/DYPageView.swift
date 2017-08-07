//
//  DYPageView.swift
//  DYPlayer
//
//  Created by dyLiu on 2017/8/2.
//  Copyright © 2017年 dyLiu. All rights reserved.
//

import UIKit

class DYPageView: UIView {
    
    fileprivate var titles: [String]!
    fileprivate var style: DYTitleStyle!
    fileprivate var childVCs: [UIViewController]!
    fileprivate weak var parentVC: UIViewController!
    
    fileprivate var titleView: DYTitleView!
    fileprivate var contentView: DYContentView!
    
    init(frame: CGRect, titles: [String], style: DYTitleStyle, childVCs: [UIViewController], parentVC: UIViewController) {
        super.init(frame: frame)
        assert(titles.count == childVCs.count, "标题&控制器个数不同，请检测！！！")
        self.titles = titles
        self.style = style
        self.childVCs = childVCs
        self.parentVC = parentVC
        parentVC.automaticallyAdjustsScrollViewInsets = false
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK:- UI
extension DYPageView {
    fileprivate func setupUI() {
        titleView = DYTitleView(frame: CGRect(x: 0, y: 0, width: frame.width, height: style.lineHeight), titles: titles, style: style)
        titleView.delegate = self
        addSubview(titleView)
        
        contentView = DYContentView(frame: CGRect(x: 0, y: style.lineHeight, width: frame.width, height: frame.height - style.lineHeight), childVCs: childVCs, parentVC: parentVC)
        contentView.delegate = self
        addSubview(contentView)
    }
}

//MARK:- DYTitleViewDelegate
extension DYPageView: DYTitleViewDelegate {
    func titleView(_ titleView: DYTitleView, selectedIndex index: Int) {
        contentView.setCurrentIndex(index)
    }
}

//MARK:- DY
extension DYPageView: DYContentViewDelegate {
    
    func contentView(_ contentView: DYContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        titleView.setTitleWithProgress(progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
    
    func contentViewEndScroll(_ contentView: DYContentView) {
        titleView.titleContentViewDidEndScroll()
    }
}

