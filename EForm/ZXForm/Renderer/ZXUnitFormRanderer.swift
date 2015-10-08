//
//  ZXUnitFormRanderer.swift
//  ydzs
//
//  Created by 葛枝鑫 on 15/9/29.
//  Copyright © 2015年 葛枝鑫. All rights reserved.
//

import UIKit

public class ZXUnitFormRanderer: NSObject {
    
    //MARK: - 属性
    public weak var view: ZXFormView?
    public weak var positionManager: ZXFormPositionManager?
    
    public var heighleightIndexPath: ZXIndexPath? = nil
    
    var isFixedFirstLine: Bool = false
    var isFixedFirstRow: Bool = false

    public var backgroundColor: UIColor = UIColor.clearColor()
    public var borderColor: UIColor = UIColor(hex: 0xb0b0b0)
    public var borderWidth: CGFloat = 0.3
    public var textAlignment: NSTextAlignment = .Center
    public var textFont: UIFont = UIFont.systemFontOfSize(14)
    public var textColor: UIColor = UIColor.blackColor()
    
    //MARK: - Init
    public init(view: ZXFormView, positionManager: ZXFormPositionManager) {
        super.init()
        self.view = view
        self.positionManager = positionManager
    }
    
    //MARK: - 视图渲染
    public func drawUnitForm(context context: CGContext?) {
        guard let view = self.view else {
            return
        }
        guard let dataSource = view.dataSource else {
            return
        }
        
        let rowsAndLines = dataSource.formViewRowsAndLines(view)
        if rowsAndLines.rowCount == 0 || rowsAndLines.lineCount == 0 {
            return
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
        
        for var row = positionManager!.currentStartIndexPath.row; row <= positionManager!.currentEndIndexPath.row; row++ {
            if self.isFixedFirstRow && row == 0 {
                continue
            }
            for var line = positionManager!.currentStartIndexPath.line; line <= positionManager!.currentEndIndexPath.line; line++ {
                if self.isFixedFirstLine && line == 0 {
                    continue
                }
                let indexPath = ZXIndexPath(row: row, line: line)
                let rectAtIndexPath = positionManager!.rectForIndexPath(indexPath)
                let options = dataSource.formView(view, normalUnitAppearance: indexPath)
                self.setOptions(options)
                
                UIGraphicsPushContext(context)
                CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor)
                CGContextFillRect(context, rectAtIndexPath)
                UIGraphicsPopContext()
                
                self.drawBorderLineOfUnitForm(context: context, rect: rectAtIndexPath)
                self.drawDataInRect(context, rect: rectAtIndexPath, indexPath: indexPath)
                self.drawHeighlightUintForm(context, rect: rectAtIndexPath, indexPath: indexPath)
            }
        }
        
        self.drawFixedUnitForm(context: context)
    }
    
    internal func drawFixedUnitForm(context context: CGContext?) {
        guard let view = self.view else {
            return
        }
        guard let dataSource = view.dataSource else {
            return
        }
       
        
        if self.isFixedFirstLine {
            for var row = positionManager!.currentStartIndexPath.row; row <= positionManager!.currentEndIndexPath.row; row++ {
                let indexPath = ZXIndexPath(row: row, line: 0)
                let rectAtIndexPath = positionManager!.rectOfFixedUnitForm(indexPath)
                let options = dataSource.formView(view, normalUnitAppearance: indexPath)
                self.setOptions(options)
                
                UIGraphicsPushContext(context)
                CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor)
                CGContextFillRect(context, rectAtIndexPath)
                UIGraphicsPopContext()
                
                self.drawBorderLineOfUnitForm(context: context, rect: rectAtIndexPath)
                
                self.drawDataInRect(context, rect: rectAtIndexPath, indexPath: indexPath)
                
                if let heighleightIndexPath = self.heighleightIndexPath {
                    let lineIndexPath = ZXIndexPath(row: heighleightIndexPath.row, line: 0)
                    let rect = positionManager!.rectOfFixedUnitForm(lineIndexPath)
                    
                    UIGraphicsPushContext(context)
                    CGContextSetFillColorWithColor(context, UIColor(red: 36 / 255, green: 36 / 255, blue: 36 / 255, alpha: 0.01).CGColor)
                    CGContextFillRect(context, rect)
                    UIGraphicsPopContext()
                }
            }
            
        }
        
        if self.isFixedFirstRow {
            for var line = positionManager!.currentStartIndexPath.line; line <= positionManager!.currentEndIndexPath.line; line++ {
                let indexPath = ZXIndexPath(row: 0, line: line)
                let rectAtIndexPath = positionManager!.rectOfFixedUnitForm(indexPath)
                let options = dataSource.formView(view, normalUnitAppearance: indexPath)
                self.setOptions(options)
                
                UIGraphicsPushContext(context)
                CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor)
                CGContextFillRect(context, rectAtIndexPath)
                UIGraphicsPopContext()
                
                self.drawBorderLineOfUnitForm(context: context, rect: rectAtIndexPath)
                self.drawDataInRect(context, rect: rectAtIndexPath, indexPath: indexPath)
                
                if let heighleightIndexPath = self.heighleightIndexPath {
                    let lineIndexPath = ZXIndexPath(row: 0, line: heighleightIndexPath.line)
                    let rect = positionManager!.rectOfFixedUnitForm(lineIndexPath)
                    
                    UIGraphicsPushContext(context)
                    CGContextSetFillColorWithColor(context, UIColor(red: 66 / 255, green: 66 / 255, blue: 66 / 255, alpha: 0.005).CGColor)
                    CGContextFillRect(context, rect)
                    UIGraphicsPopContext()
                }
            }
            
        }
        
        if self.isFixedFirstLine && isFixedFirstRow {
            
            let indexPath = ZXIndexPath(row: 0, line: 0)
            let rect00 = positionManager!.rectOfFixedUnitForm(indexPath)
            
            let indexPath01 = ZXIndexPath(row: 0, line: 1)
            let rect01 = positionManager!.rectOfFixedUnitForm(indexPath01)
            let indexPath10 = ZXIndexPath(row: 1, line: 0)
            let rect10 = positionManager!.rectOfFixedUnitForm(indexPath10)
            
            let rectFill01 = CGRect(x: rect00.origin.x, y: rect00.origin.y + rect00.size.height - 1, width: rect01.size.width, height: rect01.origin.y - rect00.origin.y - rect00.size.height + 1)
            var options = dataSource.formView(view, normalUnitAppearance: indexPath01)
            self.setOptions(options)
            UIGraphicsPushContext(context)
            CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor)
            CGContextFillRect(context, rectFill01)
            UIGraphicsPopContext()
            
            var lineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
            
            
//            self.drawBorderLineOfUnitForm(context: context, rect: rectFill01)
            lineSegmentsBuffer[0].x = rectFill01.origin.x + rectFill01.size.width
            lineSegmentsBuffer[0].y = rectFill01.origin.y
            lineSegmentsBuffer[1].x = rectFill01.origin.x + rectFill01.size.width
            lineSegmentsBuffer[1].y = rectFill01.origin.y + rectFill01.size.height
            CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor)
            CGContextSetLineWidth(context, self.borderWidth)
            CGContextStrokeLineSegments(context, lineSegmentsBuffer, 2)
            UIGraphicsPopContext()
            
            let rectFill10 =  CGRect(x: rect00.origin.x + rect00.size.width - 1, y: rect00.origin.y, width: rect10.origin.x - rect00.origin.x - rect00.size.width + 1, height: rect00.height)
            options = dataSource.formView(view, normalUnitAppearance: indexPath10)
            self.setOptions(options)
            UIGraphicsPushContext(context)
            CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor)
            CGContextFillRect(context, rectFill10)
            UIGraphicsPopContext()
            
            lineSegmentsBuffer[0].x = rectFill10.origin.x
            lineSegmentsBuffer[0].y = rectFill10.origin.y + rectFill10.size.height
            lineSegmentsBuffer[1].x = rectFill10.origin.x + rectFill10.size.width
            lineSegmentsBuffer[1].y = rectFill10.origin.y + rectFill10.size.height
            CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor)
            CGContextSetLineWidth(context, self.borderWidth)
            CGContextStrokeLineSegments(context, lineSegmentsBuffer, 2)
            UIGraphicsPopContext()
            
            options = dataSource.formView(view, normalUnitAppearance: indexPath)
            self.setOptions(options)
            
            UIGraphicsPushContext(context)
            CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor)
            CGContextFillRect(context, rect00)
            UIGraphicsPopContext()
            
            self.drawBorderLineOfUnitForm(context: context, rect: rect00)
        }
    }
    
    private func drawBorderLineOfUnitForm(context context: CGContext?, rect: CGRect) {
        var lineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())

        lineSegmentsBuffer[0].x = rect.origin.x
        lineSegmentsBuffer[0].y = rect.origin.y + rect.size.height
        lineSegmentsBuffer[1].x = rect.origin.x + rect.size.width
        lineSegmentsBuffer[1].y = rect.origin.y + rect.size.height
        CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor)
        CGContextSetLineWidth(context, self.borderWidth)
        CGContextStrokeLineSegments(context, lineSegmentsBuffer, 2)
        UIGraphicsPopContext()

        lineSegmentsBuffer[0].x = rect.origin.x + rect.size.width
        lineSegmentsBuffer[0].y = rect.origin.y
        lineSegmentsBuffer[1].x = rect.origin.x + rect.size.width
        lineSegmentsBuffer[1].y = rect.origin.y + rect.size.height
        CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor)
        CGContextSetLineWidth(context, self.borderWidth)
        CGContextStrokeLineSegments(context, lineSegmentsBuffer, 2)
        UIGraphicsPopContext()
    }
    
    internal func drawDataInRect(context: CGContext?, rect: CGRect, indexPath: ZXIndexPath) {
        guard let view = self.view else {
            return
        }
        guard let dataSource = view.dataSource else {
            return
        }
        
        guard let data = dataSource.formView(view, dataForUnitForIndexPath: indexPath) else {
            return
        }
        
        let point = CGPoint(x: rect.origin.x + 3, y: rect.origin.y + (rect.height - self.textFont.lineHeight) / 2)
        let size = CGSize(width: rect.width - 6, height: self.textFont.lineHeight + 1)
        let realRect = CGRect(origin: point, size: size)
        
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = self.textAlignment
        let attr = [
            NSForegroundColorAttributeName: self.textColor,
            NSFontAttributeName: self.textFont,
            NSParagraphStyleAttributeName: paraStyle
        ]
        UIGraphicsPushContext(context)
        (data as NSString).drawInRect(realRect, withAttributes:attr)
        UIGraphicsPopContext()
    }
    
    internal func drawHeighlightUintForm(context: CGContext?, rect: CGRect, indexPath: ZXIndexPath) {
        guard let view = self.view else {
            return
        }
        guard let dataSource = view.dataSource else {
            return
        }
        guard let heighleightIndexPath = self.heighleightIndexPath else {
           return
        }
        
        if heighleightIndexPath.row == indexPath.row && heighleightIndexPath.line == indexPath.line {
           let options = dataSource.formView(view, heighlightAppearance: heighleightIndexPath)
            self.setOptions(options)
            let drawRect = CGRect(x: rect.origin.x + 0.5, y: rect.origin.y + 0.5, width: rect.size.width - 1, height: rect.size.height - 1)
            UIGraphicsPushContext(context)
            CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor)
            CGContextSetLineWidth(context, self.borderWidth)
            CGContextAddRect(context, drawRect)
            CGContextStrokePath(context)
            UIGraphicsPopContext()
        }
    }
    
    
    //MARK: - 计算相关函数
    private func setOptions(options: [ZXUnitFormOption]) {
        for option in options {
            switch option {
            case let .BorderColor(value):
                self.borderColor = value
            case let .BorderWidth(value):
                self.borderWidth = value
            case let .BackgroundColor(value):
                self.backgroundColor = value
            case let .TextAlignment(value):
                self.textAlignment = value
            case let .TextColor(value):
                self.textColor = value
            case let .TextFont(value):
                self.textFont = value
            }
        }
    }
}
