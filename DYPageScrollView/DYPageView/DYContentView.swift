//
//  DYContentView.swift
//  DYPlayer
//
//  Created by dyLiu on 2017/8/2.
//  Copyright © 2017年 dyLiu. All rights reserved.
//

import UIKit

//MARK:- 协议
@objc protocol DYContentViewDelegate: class {
    func contentView(_ contentView: DYContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int)
    @objc optional func contentViewEndScroll(_ contentView: DYContentView)
}

private let kCollectionID = "collectionID"
class DYContentView: UIView {
//MARK:- 子控制器
    fileprivate var childVCs: [UIViewController]!
//MARK:- 父控制器
    fileprivate weak var parentVC: UIViewController!
//MARK:- 是否禁止滚动
    fileprivate var isForbidScrollDelegate: Bool = false
//MARK:- 起始偏移量
    fileprivate var startOffsetX: CGFloat = 0
//MARK:- collectionView
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kCollectionID)

        return collectionView
    }()
//MARK:- delegate
    weak var delegate: DYContentViewDelegate?
    
    init(frame: CGRect, childVCs: [UIViewController], parentVC: UIViewController) {
        
        super.init(frame: frame)
        self.childVCs = childVCs
        self.parentVC = parentVC
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension DYContentView {
    fileprivate func setupUI() {
        for childVC in childVCs {
            parentVC.addChildViewController(childVC)
        }
        addSubview(collectionView)
    }
}

//MARK:- UICollectionViewDataSource
extension DYContentView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVCs.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCollectionID, for: indexPath)
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        let childVC = childVCs[indexPath.item]
        childVC.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(childVC.view)
        return cell
    }
    
}

//MARK:- UICollectionViewDelegate
extension DYContentView: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        isForbidScrollDelegate = false
        startOffsetX = scrollView.contentOffset.x
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isForbidScrollDelegate {return}
        
        var progress: CGFloat = 0
        var  sourceIndex: Int = 0
        var targetIndex: Int = 0
        
        let currentOffsetX = scrollView.contentOffset.x
        let scrollViewW = scrollView.bounds.width
        if currentOffsetX > startOffsetX {
            
            progress = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW)
            sourceIndex = Int(currentOffsetX / scrollViewW)
            
            targetIndex = sourceIndex + 1
            if targetIndex > childVCs.count {
                targetIndex = childVCs.count - 1
            }
            
            if currentOffsetX - startOffsetX == scrollViewW {
                progress = 1
                targetIndex = sourceIndex
            }
            
        } else {
            
            progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW))
            
            targetIndex = Int(currentOffsetX / scrollViewW)
            
            sourceIndex = targetIndex + 1
            if sourceIndex >= childVCs.count {
                sourceIndex = childVCs.count - 1
            }
            
        }
        
        delegate?.contentView(self, progress: progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
 
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.contentViewEndScroll?(self)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            delegate?.contentViewEndScroll?(self)
        }
    }
    
}

//MARK:- 对外开发
extension DYContentView {
    func setCurrentIndex(_ currentIndex: Int) {
        // 1.记录需要禁止执行代理方法
        isForbidScrollDelegate = true
        
        // 2.滚动正确的位置
        let offsetX = CGFloat(currentIndex) * collectionView.frame.width
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }
}




