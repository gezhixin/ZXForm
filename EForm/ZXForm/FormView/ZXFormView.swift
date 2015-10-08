//
//  ZXFormView.swift
//  ydzs
//
//  Created by 葛枝鑫 on 15/9/27.
//  Copyright © 2015年 葛枝鑫. All rights reserved.
//

import UIKit

public func UIGraphicsPushContext(context: CGContext?) {
    
    guard let context = context else {
        return
    }
    UIGraphicsPushContext(context)
}

@objc public protocol ZXFormDelegate: NSObjectProtocol {
    optional func formView(view: ZXFormView, tapAtIndexPath indexPath: ZXIndexPath)
    optional func formView(view: ZXFormView, doubleTapAtIndexPath indexPath: ZXIndexPath)
    optional func formView(view: ZXFormView, longTapAtIndexPath indexPath: ZXIndexPath)
}

public protocol ZXFormDataSource: NSObjectProtocol {
    
    func formViewRowsAndLines(view: ZXFormView) -> ZXIndexPath
    func formViewAppearance(view: ZXFormView) -> [ZXFormAppearanceOption]
    func formView(view: ZXFormView, heightForLine line: Int) -> CGFloat
    func formView(view: ZXFormView, widthForRow row: Int) -> CGFloat
    func formView(view: ZXFormView, dataForUnitForIndexPath indexPath: ZXIndexPath) -> String?
    func formView(view: ZXFormView, normalUnitAppearance indexPath: ZXIndexPath) -> [ZXUnitFormOption]
    func formView(view: ZXFormView, heighlightAppearance indexPath: ZXIndexPath) -> [ZXUnitFormOption]
}

public class ZXIndexPath: NSObject {
    var row: Int = 0
    var line: Int = 0
    
    var rowCount: Int = 0
    var lineCount: Int = 0
    
    init(row: Int, line: Int) {
        self.row = row
        self.line = line
    }
    
    init(rowCount: Int, lineCount: Int) {
        self.rowCount = rowCount
        self.lineCount = lineCount
    }
}

public enum ZXFormAppearanceOption {
    case LineColor(UIColor)
    case LineWidth(CGFloat)
    case FixedFirstLine(Bool)
    case FixedFirstRow(Bool)
}

public enum ZXUnitFormOption {
    case BackgroundColor(UIColor)
    case BorderColor(UIColor)
    case BorderWidth(CGFloat)
    case TextAlignment(NSTextAlignment)
    case TextFont(UIFont)
    case TextColor(UIColor)
}

public class ZXFormView: UIView {
    
    //MAEK: - Property
    /// 代理
    public weak var dataSource: ZXFormDataSource?
    public weak var delegate: ZXFormDelegate?
    
    public var postionManager: ZXFormPositionManager!
    
    /// 渲染
    public var unitFormRanderer: ZXUnitFormRanderer!
    
    var dataSeted: Bool = false
    
    /// 手势
    internal var panGR: UIPanGestureRecognizer!
    internal var tapGR: UITapGestureRecognizer!
    internal var longPressGR: UILongPressGestureRecognizer!

    //MARK:- Init
    public override func awakeFromNib() {
        panGR = UIPanGestureRecognizer(target: self, action: "panAction:")
        tapGR = UITapGestureRecognizer(target: self, action: "tapAction:")
        
        longPressGR = UILongPressGestureRecognizer(target: self, action: "longPressAction:")
        self.addGestureRecognizer(panGR)
        self.addGestureRecognizer(tapGR)
        self.addGestureRecognizer(longPressGR)
        self.initProperty()
    }
    
    private func initProperty() {
        self.postionManager = ZXFormPositionManager(view: self)
        self.unitFormRanderer = ZXUnitFormRanderer(view: self, positionManager: self.postionManager)
    }
    
    public func heighlightUnitFormOfIndexPath(indexPath: ZXIndexPath) {
        self.unitFormRanderer.heighleightIndexPath = indexPath
        self.setNeedsDisplay()
    }
    
    public func relord() {
        self.postionManager.calcuPostion()
        self.setNeedsDisplay()
    }
    
    //MARK: - 视图绘制
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        self.unitFormRanderer.drawUnitForm(context: context)
        
        CGContextRestoreGState(context)
    }
    
    //MARK: - 手势回调
    var beganBounds: CGRect = CGRectZero
    func panAction(gesture: UIPanGestureRecognizer) {
        let point = gesture.translationInView(self)
       
        if gesture.state == .Began {
          beganBounds = self.bounds
        }
        
        var tempBounds = self.bounds
        tempBounds.origin.x = beganBounds.origin.x - point.x
        tempBounds.origin.y = beganBounds.origin.y - point.y
        
        if gesture.state == .Ended {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                tempBounds.origin.x = tempBounds.origin.x > 0 ? tempBounds.origin.x : 0
                tempBounds.origin.y = tempBounds.origin.y > 0 ? tempBounds.origin.y : 0
                tempBounds.origin.x = tempBounds.origin.x + tempBounds.size.width > self.postionManager.realEndPosition.x ? self.postionManager.realEndPosition.x - self.bounds.size.width : tempBounds.origin.x
                tempBounds.origin.y = tempBounds.origin.y + tempBounds.size.height > self.postionManager.realEndPosition.y ? self.postionManager.realEndPosition.y - self.bounds.size.height : tempBounds.origin.y
                self.bounds = tempBounds
            })
        } else {
            self.bounds = tempBounds
        }
    }
    
    func tapAction(gesture: UITapGestureRecognizer) {
        guard let delegate = self.delegate else {
            return
        }
        
        let point = gesture.locationInView(self)
        if let indexPath = postionManager.indexPathOfPointAtShowingView(point) {
            if delegate.respondsToSelector("formView:tapAtIndexPath:") {
                delegate.formView!(self, tapAtIndexPath: indexPath)
            }
        }
    }
    
    func longPressAction(gesture: UITapGestureRecognizer) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        let point = gesture.locationInView(self)
        if let indexPath = postionManager.indexPathOfPointAtShowingView(point) {
            if delegate.respondsToSelector("formView:longTapAtIndexPath:") {
                delegate.formView!(self, longTapAtIndexPath: indexPath)
            }
        }
    }
    
    deinit {
        self.removeObserver(self.postionManager, forKeyPath: "bounds")
        self.removeObserver(self.postionManager, forKeyPath: "frame")
        self.postionManager = nil
        self.unitFormRanderer = nil
    }
}
