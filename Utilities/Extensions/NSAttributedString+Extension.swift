//
//  NSAttributedString+Extension.swift
//  QRScanner
//

import UIKit

extension NSAttributedString {
    static func attributedString(fString string1: String, fSColor color1: UIColor, fSFont font1: UIFont, sString string2: String="", sSColor color2: UIColor=UIColor.black, sSFont font2: UIFont=UIFont.systemFont(ofSize: 16), lineHeight: CGFloat=NSParagraphStyle().minimumLineHeight, lineBreakMode: NSLineBreakMode = .byTruncatingTail) -> NSMutableAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.lineBreakMode = lineBreakMode
        
        let attString = NSMutableAttributedString(string: string1, attributes: [NSAttributedString.Key.font : font1, .foregroundColor: color1, .paragraphStyle: paragraphStyle ])
        
        if string2 != "" {
            attString.append(NSAttributedString(string: string2, attributes: [NSAttributedString.Key.font : font2, .foregroundColor: color2, .paragraphStyle: paragraphStyle ]))
        }
        
        return attString
    }
}
