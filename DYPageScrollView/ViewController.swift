//
//  ViewController.swift
//  DYPageScrollView
//
//  Created by dyLiu on 2017/8/7.
//  Copyright © 2017年 dyLiu. All rights reserved.
//

import UIKit

let kScreenH: CGFloat = UIScreen.main.bounds.size.height
let kScreenW: CGFloat = UIScreen.main.bounds.size.width
let kNavigationBarH: CGFloat = 44
let kStatusBarH: CGFloat = 20

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

}

//MARK:- UI
extension ViewController {
    fileprivate func setupUI() {
        let style = DYTitleStyle()
        style.isScrollEnable = true
        style.isNeedScale = true
        style.isShowBottomLine = true
        style.isShowCover = true
        let titles: [String] = ["全部", "游戏", "小鲜肉", "颜值", "萌妹", "趣玩", "直播", "体育", "更多分类"]
        var childVCs = [UIViewController]()
        for title in titles {
            let childVC = UIViewController()
            print("\(title)")
            childVC.view.backgroundColor = UIColor.randomColor()
            childVCs.append(childVC)
        }
        let frame = CGRect(x: 0, y: kStatusBarH, width: kScreenW, height: kScreenH - kStatusBarH - 49.0)
        let pageView = DYPageView(frame: frame, titles: titles, style: style, childVCs: childVCs, parentVC: self)
        view.addSubview(pageView)
    }
}
