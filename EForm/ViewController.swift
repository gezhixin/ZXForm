//
//  ViewController.swift
//  EForm
//
//  Created by 葛枝鑫 on 15/10/8.
//  Copyright © 2015年 葛枝鑫. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ZXFormDelegate, ZXFormDataSource {

    @IBOutlet weak var formView: ZXFormView!
    
    var formHeaderText = ["姓 名", "学 号", "性 别", "出生年月"]
    var formHeaderWidth: [CGFloat] = [1, 2, 1, 2]
    let students = [
        ["小 明", "34567658", "男", "1995-01-35"],
        ["小 红", "34567657", "女", "1995-01-35"],
        ["韩梅梅", "34567656", "女", "1995-01-35"],
        ["王小虎", "34567655", "男", "1995-01-35"],
        ["白费力", "34567654", "男", "1995-01-35"],
        ["小 明", "34567654", "男", "1995-01-35"],
        ["小 明", "34567654", "男", "1995-01-35"],
        ["小 明", "34567654", "男", "1995-01-35"],
        ["小 明", "34567654", "男", "1995-01-35"],
        ["小 明", "34567654", "男", "1995-01-35"],
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.formView.dataSource = self
        self.formView.delegate = self
        self.formView.relord()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - FormDataSource
    func formViewRowsAndLines(view: ZXFormView) -> ZXIndexPath {
        return ZXIndexPath(rowCount: 5, lineCount: 234)
    }
    
    func formViewAppearance(view: ZXFormView) -> [ZXFormAppearanceOption] {
        let options = [
            .FixedFirstLine(true),
            .FixedFirstRow(true),
            
            ] as [ZXFormAppearanceOption]
        return options
    }
    
    func formView(view: ZXFormView, heightForLine line: Int) -> CGFloat {
        return 30
    }
    
    func formView(view: ZXFormView, widthForRow row: Int) -> CGFloat {
        if row == 0 {
            return 25
        }
        return (UIScreen.mainScreen().bounds.size.width - 25) * self.formHeaderWidth[row - 1] / 6
    }
    
    func formView(view: ZXFormView, dataForUnitForIndexPath indexPath: ZXIndexPath) -> String? {
        if indexPath.row == 0 && indexPath.line != 0 {
            return "\(indexPath.line)"
        } else if indexPath.line == 0 && indexPath.row != 0 {
            if indexPath.row - 1 < self.formHeaderText.count {
                return self.formHeaderText[indexPath.row - 1]
            } else {
                return ""
            }
        } else if indexPath.line == 0 && indexPath.row == 0 {
            return ""
        } else {
            if indexPath.line - 1 < self.students.count {
                return self.students[indexPath.line - 1][indexPath.row - 1]
            } else {
                return ""
            }
        }
    }
    
    func formView(view: ZXFormView, normalUnitAppearance indexPath: ZXIndexPath) -> [ZXUnitFormOption] {
        if indexPath.row == 0 {
            let options = [
                .BackgroundColor(UIColor(hex: 0xE7E7E7)),
                .BorderColor(UIColor(hex: 0xb0b0b0)),
                .BorderWidth(0.5),
                .TextFont(UIFont.systemFontOfSize(10)),
                .TextColor(UIColor.blackColor()),
                .TextAlignment(.Center),
                ] as [ZXUnitFormOption]
            return options
        } else if indexPath.line == 0 {
            let options = [
                .BackgroundColor(UIColor(hex: 0xE7E7E7)),
                .BorderColor(UIColor(hex: 0xb0b0b0)),
                .BorderWidth(0.5),
                .TextFont(UIFont.systemFontOfSize(15)),
                .TextAlignment(.Center),
                ] as [ZXUnitFormOption]
            return options
        } else {
            let options = [
                .BackgroundColor(UIColor.whiteColor()),
                .BorderColor(UIColor(hex: 0xb0b0b0)),
                .BorderWidth(0.5),
                .TextFont(UIFont.systemFontOfSize(14)),
                .TextColor(UIColor.blackColor()),
                .TextAlignment(.Center),
                ] as [ZXUnitFormOption]
            return options
        }
    }
    func formView(view: ZXFormView, heighlightAppearance indexPath: ZXIndexPath) -> [ZXUnitFormOption] {
        let options = [
            .BorderColor(UIColor(hex: 0x27ae60)),
            .BorderWidth(1.5)
            ] as [ZXUnitFormOption]
        return options
    }
    
    func formView(view: ZXFormView, tapAtIndexPath indexPath: ZXIndexPath) {
        if indexPath.row == 0 || indexPath.line == 0 {
            return
        }
        view.heighlightUnitFormOfIndexPath(indexPath)
        self.becomeFirstResponder()
    }
    
    func formView(view: ZXFormView, longTapAtIndexPath indexPath: ZXIndexPath) {
    }

}

