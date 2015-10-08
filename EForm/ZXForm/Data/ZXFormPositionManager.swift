//
//  ZXFormPositionManager.swift
//  ydzs
//
//  Created by 葛枝鑫 on 15/10/3.
//  Copyright © 2015年 葛枝鑫. All rights reserved.
//

import UIKit

public class ZXFormPositionManager: NSObject {
    
    private var kovCentext = 0
    
    public weak var view: ZXFormView?
    
    var isFixedFirstLine: Bool = false
    var isFixedFirstRow: Bool = false
    
//    public var 
    
    public var formLinesAndRows: ZXIndexPath {
        guard let view = self.view else {
            return ZXIndexPath(rowCount: 0, lineCount: 0)
        }
        guard let dataSource = view.dataSource else {
            return ZXIndexPath(rowCount: 0, lineCount: 0)
        }
        let indexPath = dataSource.formViewRowsAndLines(view)
        return indexPath
    }
    
    public var originalBounds: CGRect = CGRectZero
    public var lastBounds: CGRect = CGRectZero
    
    public var currentStartIndexPath: ZXIndexPath! = ZXIndexPath(row: 0, line: 0)
    public var currentEndIndexPath: ZXIndexPath! = ZXIndexPath(row: 0, line: 0)
    
    public var currentStartPostion: CGPoint = CGPoint(x: 0, y: 0)
    public var currentEndPostion: CGPoint {
        guard let view = self.view  else {
            return CGPoint(x: 0, y: 0)
        }
        var tempPoint = self.currentStartPostion
        tempPoint.x += view.frame.width
        tempPoint.y += view.frame.height
        return tempPoint
    }
    
    public var realEndPosition: CGPoint {
        guard let view = self.view else {
            return CGPointZero
        }
        guard let dataSource = view.dataSource else {
            return CGPointZero
        }
        
        var heightCount = CGFloat(0)
        var widthCount = CGFloat(0)
        for var line = 0; line < self.formLinesAndRows.lineCount; line++ {
            let heightOfLine = dataSource.formView(view, heightForLine: line)
            heightCount += heightOfLine
        }
        
        for var row = 0; row < self.formLinesAndRows.rowCount; row++ {
            let rowWidth = dataSource.formView(view, widthForRow: row)
            widthCount += rowWidth
        }
        
        return CGPoint(x: widthCount, y: heightCount)
    }
   
    public init(view: ZXFormView) {
        super.init()
        self.view = view
        if let view = self.view {
            view.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: &kovCentext)
            view.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.New, context: &kovCentext)
        }
        self.calcuPostion()
    }
    
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let keyPath = keyPath {
            if keyPath == "frame" {
                self.calcuPostion()
                self.view?.setNeedsDisplay()
            } else if keyPath == "bounds" {
                self.calcuPostion()
                self.view?.setNeedsDisplay()
            }
        }
    }
    
    // MARK: - 位置计算函数
    public func calcuPostion() {
        guard let view = self.view else {
            return
        }
        guard let dataSource = view.dataSource else {
            return
        }
        
        self.originalBounds = view.bounds
        self.lastBounds = view.bounds
        var heightCount = CGFloat(0)
        var widthCount = CGFloat(0)
        for var line = 0; line < self.formLinesAndRows.lineCount; line++ {
            
            let heightOfLine = dataSource.formView(view, heightForLine: line)
            heightCount += heightOfLine
            
            if heightCount >= view.bounds.origin.y {
                self.currentStartIndexPath.line = line
                self.currentStartPostion.y = heightCount - heightOfLine
                break
            }
        }
        
        for var row = 0; row < self.formLinesAndRows.rowCount; row++ {
            let rowWidth = dataSource.formView(view, widthForRow: row)
            widthCount += rowWidth
            if widthCount >= view.bounds.origin.x {
                self.currentStartIndexPath.row = row
                self.currentStartPostion.x = widthCount - rowWidth
                break
            }
        }
        
        heightCount = 0
        for var line = self.currentStartIndexPath.line; line < self.formLinesAndRows.lineCount; line++ {
            let heightOfLine = dataSource.formView(view, heightForLine: line)
            line = (line + 1) < self.formLinesAndRows.lineCount ? (line + 1) : line
            self.currentEndIndexPath.line = line
            if heightCount > view.bounds.size.height {
                break
            }
            heightCount += heightOfLine
        }
        
        widthCount = 0
        for var row = self.currentStartIndexPath.row; row < self.formLinesAndRows.rowCount; row++ {
            let rowWidth = dataSource.formView(view, widthForRow: row)
            row = (row + 1) < self.formLinesAndRows.rowCount ? (row + 1) : row
            self.currentEndIndexPath.row = row
            if widthCount > view.bounds.size.width {
                break
            }
            widthCount += rowWidth
        }
    }
    
    public func rectForIndexPath(indexPath: ZXIndexPath) -> CGRect {
        guard let view = self.view else {
            return CGRectZero
        }
        guard let dataSource = view.dataSource else {
            return CGRectZero
        }
        
        var startPoint: CGPoint = CGPointZero
        var x = CGFloat(0)
        var y = CGFloat(0)
        for var i = 0; i < indexPath.row; i++ {
            let rowWidth = dataSource.formView(view, widthForRow: i)
            x += rowWidth
        }
        
        for var j = 0; j < indexPath.line; j++ {
            let lineHeight = dataSource.formView(view, heightForLine: j)
            y += lineHeight
        }
        
        startPoint.x = x
        startPoint.y = y
        let width = dataSource.formView(view, widthForRow: indexPath.row)
        let height = dataSource.formView(view, heightForLine: indexPath.line)
        return CGRect(origin: startPoint, size: CGSize(width: width, height: height))
    }
    
    public func rectOfFixedUnitForm(indexPath: ZXIndexPath) -> CGRect {
        
        guard let view = self.view else {
            return CGRectZero
        }
        guard let dataSource = view.dataSource else {
            return CGRectZero
        }
        
        let formOptions = dataSource.formViewAppearance(view)
        for option in formOptions {
            switch option {
            case let .FixedFirstRow(value):
                self.isFixedFirstRow = value
            case let .FixedFirstLine(value):
                self.isFixedFirstLine = value
            default:
                break
            }
        }
        
        var startPoint: CGPoint = CGPointZero
        var x = CGFloat(0)
        var y = CGFloat(0)
        
        if indexPath.row == 0 && self.isFixedFirstRow{
            x = view.bounds.origin.x
        } else {
            for var i = 0; i < indexPath.row; i++ {
                let rowWidth = dataSource.formView(view, widthForRow: i)
                x += rowWidth
            }
        }
       
        if indexPath.line == 0 && self.isFixedFirstLine {
            y = view.bounds.origin.y
        } else {
            for var j = 0; j < indexPath.line; j++ {
                let lineHeight = dataSource.formView(view, heightForLine: j)
                y += lineHeight
            }
        }
        
        startPoint.x = x
        startPoint.y = y
        let width = dataSource.formView(view, widthForRow: indexPath.row)
        let height = dataSource.formView(view, heightForLine: indexPath.line)
        return CGRect(origin: startPoint, size: CGSize(width: width, height: height))
    }
    
    public func indexPathOfPointAtShowingView(point: CGPoint) -> ZXIndexPath? {
        guard let view = self.view else {
            return nil
        }
        guard let dataSource = view.dataSource else {
            return nil
        }
       
        let formOptions = dataSource.formViewAppearance(view)
        for option in formOptions {
            switch option {
            case let .FixedFirstRow(value):
                self.isFixedFirstRow = value
            case let .FixedFirstLine(value):
                self.isFixedFirstLine = value
            default:
                break
            }
        }
        
        if self.isFixedFirstRow {
            for var line = currentStartIndexPath.line; line <= currentEndIndexPath.line; line++ {
                let indexPath = ZXIndexPath(row: 0, line: line)
                let rectAtIndexPath = rectOfFixedUnitForm(indexPath)
                if point.x >= rectAtIndexPath.origin.x && point.x <= rectAtIndexPath.origin.x + rectAtIndexPath.size.width && point.y >= rectAtIndexPath.origin.y && point.y <= rectAtIndexPath.origin.y + rectAtIndexPath.size.height {
                    return indexPath
                }
            }
        }
        
        if self.isFixedFirstLine {
            for var row = currentStartIndexPath.row; row <= currentEndIndexPath.row; row++ {
                let indexPath = ZXIndexPath(row: row, line: 0)
                let rectAtIndexPath = rectOfFixedUnitForm(indexPath)
                if point.x >= rectAtIndexPath.origin.x && point.x <= rectAtIndexPath.origin.x + rectAtIndexPath.size.width && point.y >= rectAtIndexPath.origin.y && point.y <= rectAtIndexPath.origin.y + rectAtIndexPath.size.height {
                    return indexPath
                }
            }
        }
        
        for var row = currentStartIndexPath.row; row <= currentEndIndexPath.row; row++ {
            for var line = currentStartIndexPath.line; line <= currentEndIndexPath.line; line++ {
                let indexPath = ZXIndexPath(row: row, line: line)
                let rectAtIndexPath = rectForIndexPath(indexPath)
                
                if point.x >= rectAtIndexPath.origin.x && point.x <= rectAtIndexPath.origin.x + rectAtIndexPath.size.width && point.y >= rectAtIndexPath.origin.y && point.y <= rectAtIndexPath.origin.y + rectAtIndexPath.size.height {
                    return indexPath
                }
            }
        }
        return nil
    }
}
