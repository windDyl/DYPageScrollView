//
//  DYTitleView.swift
//  DYPlayer
//
//  Created by dyLiu on 2017/8/2.
//  Copyright © 2017年 dyLiu. All rights reserved.
//

import UIKit

//MARK:- 协议
protocol DYTitleViewDelegate: class {
    func titleView(_ titleView: DYTitleView, selectedIndex index: Int)
}

class DYTitleView: UIView {
//MARK:- 标题
    fileprivate var titles: [String]!
//MARK:- 标题样式
    fileprivate var style: DYTitleStyle!
//MARK:- 选中title的下标
    fileprivate var currentIndex: Int = 0
//MARK:- 存储标题label
    fileprivate lazy var titleLabels: [UILabel] = [UILabel]()
//MARK:- 滚动视图
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.frame = self.bounds
        return scrollView
    }()
//MARK:- 底部分割线
    fileprivate lazy var splitLineView: UIView = {
        let spiltLineView = UIView()
        spiltLineView.backgroundColor = .lightGray
        spiltLineView.frame = CGRect(x: 0, y: self.frame.height-0.5, width: self.frame.width, height: 0.5)
        return spiltLineView
    }()
//MARK:- 滚动下划线
    fileprivate lazy var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.backgroundColor = self.style.bottomLineColor
        return bottomLine
    }()
//MARK:- 遮罩视图
    fileprivate lazy var coverView: UIView = {
        let coverView = UIView()
        coverView.alpha = 0.7
        coverView.backgroundColor = self.style.coverBgColor
        return coverView
    }()
//MARK:- 默认标题颜色的rgb值
    fileprivate lazy var normalColorRGB: (r: CGFloat, g: CGFloat, b: CGFloat) = self.getRGBWithColor(self.style.normalColor)
//MARK:- 选中标题颜色的rgb值
    fileprivate lazy var selectedColorRGB: (r: CGFloat, g: CGFloat, b: CGFloat) = self.getRGBWithColor(self.style.selectedColor)
//MARK:- 协议
    weak var delegate: DYTitleViewDelegate?
    
    init(frame: CGRect, titles: [String], style: DYTitleStyle) {
        super.init(frame: frame)
        backgroundColor = .white
        self.titles = titles
        self.style = style
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension DYTitleView {
    fileprivate func setupUI() {
        //添加scrollView
        addSubview(scrollView)
        
        //添加底部分割线
        addSubview(splitLineView)
        
        //设置标题
        setupTitleLabels()
        
        //设置标题frame
        setupTitleLabelsPosition()
        
        //设置底部滚动条
        if style.isShowBottomLine {
            setupBottomLine()
        }
        
        //添加cover view
        if style.isShowCover {
            setupCoverView()
        }
    }
    
    private func setupTitleLabels() {
        for (index, title) in titles.enumerated() {
            let label = UILabel()
            label.tag = index
            label.text = title
            label.textColor = index == 0 ? style.selectedColor : style.normalColor
            label.font = style.font
            label.textAlignment = .center
            
            label.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(titleClicked(_:)))
            label.addGestureRecognizer(gesture)
            titleLabels.append(label)
            scrollView.addSubview(label)
        }
    }
    
    private func setupTitleLabelsPosition() {
        var titleX: CGFloat = 0.0
        let titleY: CGFloat = 0.0
        var titleW: CGFloat = 0.0
        let titleH: CGFloat = frame.height
        
        let count = titles.count
        
        for (index, label) in titleLabels.enumerated() {
            
            if style.isScrollEnable {
                let rect = (label.text! as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0), options:.usesLineFragmentOrigin, attributes: [NSFontAttributeName: style.font], context: nil)
                titleW = rect.width
                
                if index == 0 {
                    titleX = style.titleMargin * 0.5
                } else {
                    titleX = titleLabels[index - 1].frame.maxX + style.titleMargin
                }
                
            } else {
                titleW = frame.width / CGFloat(count)
                titleX = titleW * CGFloat(index)
            }
            
            label.frame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
            
            //放大
            if index == 0 {
                let scale = style.isNeedScale ? style.scaleRange : 1.0
                label.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            
        }
        
        if style.isScrollEnable {
            scrollView.contentSize = CGSize(width: titleLabels.last!.frame.maxX + style.titleMargin * 0.5, height: 0)
        }
        
    }
    
    private func setupBottomLine() {
        scrollView.addSubview(bottomLine)
        bottomLine.frame = titleLabels.first!.frame
        bottomLine.frame.size.height = style.bottomLineH
        bottomLine.frame.origin.y = bounds.height - style.bottomLineH * 2
    }
    
    private func setupCoverView() {
        scrollView.insertSubview(coverView, at: 0)
        let firstLabel = titleLabels[0]
        var coverW = firstLabel.frame.width
        let coverH = style.coverH
        var coverX = firstLabel.frame.origin.x
        let coverY = (bounds.height - coverH) * 0.5
        if style.isScrollEnable {
            coverX -= style.coverMargin
            coverW += style.coverMargin * 2
        }
        coverView.frame = CGRect(x: coverX, y: coverY, width: coverW, height: coverH)
        coverView.layer.cornerRadius = style.coverRadius
        coverView.layer.masksToBounds = true
    }
    
}

//MARK:- 事件响应

extension DYTitleView {
    @objc fileprivate func titleClicked(_ tap: UITapGestureRecognizer) {
        
        guard let currentLabel = tap.view as? UILabel else {return}
        //重复点击同一按钮
        if currentLabel.tag == currentIndex {return}
        
        let oldLabel = titleLabels[currentIndex]
        //颜色改变
        currentLabel.textColor = style.selectedColor
        oldLabel.textColor = style.normalColor
        
        //保留新index
        currentIndex = currentLabel.tag
        //delegate 方法
        delegate?.titleView(self, selectedIndex: currentIndex)
        
        //title居中
        titleContentViewDidEndScroll()
        
        //bottomLine动画
        if style.isShowBottomLine {
            UIView.animate(withDuration: 0.15, animations: { 
                self.bottomLine.frame.origin.x = currentLabel.frame.origin.x
                self.bottomLine.frame.size.width = currentLabel.frame.size.width
            })
        }
        
        //放大比例
        if style.isNeedScale {
            oldLabel.transform = CGAffineTransform.identity
            currentLabel.transform = CGAffineTransform(scaleX: style.scaleRange, y: style.scaleRange)
        }
        
        //cover动画
        if style.isShowCover {
            let coverX = style.isScrollEnable ? (currentLabel.frame.origin.x - style.coverMargin) : currentLabel.frame.origin.x
            let coverW = style.isScrollEnable ? (currentLabel.frame.width + style.coverMargin * 2) : currentLabel.frame.width
            UIView.animate(withDuration: 0.15, animations: { 
                self.coverView.frame.origin.x = coverX
                self.coverView.frame.size.width = coverW
            })
        }
        print("=== \(titles[currentIndex]) ===");
    }
}

//MARK:- 获取RGB的值
extension DYTitleView {
    fileprivate func getRGBWithColor(_ color: UIColor)->(CGFloat, CGFloat, CGFloat) {
        guard let components = color.cgColor.components else {
            fatalError("请使用RGB给title赋颜色")
        }
        return (components[0]*255, components[1]*255, components[2]*255)
    }
}

//MARK:- 对外开发方法
extension DYTitleView {
    func setTitleWithProgress(_ progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        //取出source/target label
        let sourceLabel = titleLabels[sourceIndex]
        let targetLabel = titleLabels[targetIndex]
        
        //颜色渐变
        //取出颜色变化的范围
        let colorData = (selectedColorRGB.r - normalColorRGB.r, selectedColorRGB.g - normalColorRGB.g, selectedColorRGB.b - normalColorRGB.b)
        //改变sourceLabelde 字体颜色
        sourceLabel.textColor = UIColor(r: selectedColorRGB.r - progress * colorData.0, g: selectedColorRGB.g - progress * colorData.1, b: selectedColorRGB.b - progress * colorData.2)
        //改变tragetLabelde 字体颜色
        targetLabel.textColor = UIColor(r: normalColorRGB.r + progress * colorData.0, g: normalColorRGB.g + progress * colorData.1, b: normalColorRGB.b + progress * colorData.2)
        //标记index
        currentIndex = targetIndex
        
        let moveTotalX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
        let moveTotalW = targetLabel.frame.width - sourceLabel.frame.width
        //计算出滚动范围差值
        if style.isShowBottomLine {
            bottomLine.frame.size.width = sourceLabel.frame.width + moveTotalW * progress
            bottomLine.frame.origin.x = sourceLabel.frame.origin.x + moveTotalX * progress
        }
        
        //放大
        if style.isNeedScale {
            let scaleDelta = (style.scaleRange - 1.0) * progress
            sourceLabel.transform = CGAffineTransform(scaleX: style.scaleRange - scaleDelta, y: style.scaleRange - scaleDelta)
            targetLabel.transform = CGAffineTransform(scaleX: 1.0 + scaleDelta, y: 1.0 + scaleDelta)
        }
        
        //cover滚动
        if style.isShowCover {
            coverView.frame.size.width = style.isScrollEnable ? (sourceLabel.frame.width + 2 * style.coverMargin + moveTotalW * progress) : (sourceLabel.frame.width + moveTotalW * progress)
            coverView.frame.origin.x = style.isScrollEnable ? (sourceLabel.frame.origin.x - style.coverMargin + moveTotalX * progress) : (sourceLabel.frame.origin.x + moveTotalX * progress)
        }
    }
    
    func titleContentViewDidEndScroll() {
        guard style.isScrollEnable else {return}
        //获取target label
        let targetLabel = titleLabels[currentIndex]
        //计算偏移量
        var offSetX = targetLabel.center.x - bounds.width * 0.5
        if offSetX < 0 {
            offSetX = 0
        }
        
        let maxOffset = scrollView.contentSize.width - bounds.width
        if offSetX > maxOffset {
            offSetX = maxOffset
        }
        
        //滚动
        scrollView.setContentOffset(CGPoint(x: offSetX, y:0), animated: true)
    }
    
}

