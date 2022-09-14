//
//  GlobalData.swift
//  QRScanner
//

import Foundation
import UIKit

struct GlobalData {
    static var consentText: NSMutableAttributedString {
        let font: UIFont = .systemFont(ofSize: 14)
        
        let att = NSAttributedString.attributedString(fString: "The photography task to take images and videos of Prop Private Visual Content is a part of a collaborative research project led by the University of Illinois, the University of Washington, and the University of Colorado. The goal of this study is to understand the experiences, practices and challenges of blind and low vision people with sharing images and videos that potentially contain private information, to provide insights for designing tools that protect their privacy.", fSColor: .black, fSFont: font)
        
        att.append(NSAttributedString.attributedString(fString: "\n\nTo participate in this study, you will use this app called “VizPriv” to capture photos and videos of a set of simulated private objects. The study should take up to 2 hours, and we will compensate you with a $50 Amazon gift card upon completion of this study. You may refuse to participate or withdraw from the study at any time without penalty or loss of benefits to which you are otherwise entitled. Please review the full consent form in the following link before proceeding: Click to review full consent form", fSColor: .black, fSFont: font))
        
        att.append(NSAttributedString.attributedString(fString: "\n\n By checking the “I understand and agree” field, you agree to the following: I am 18 years old or older. I have read the consent information and I volunteer to take part in this study. Please enter the unique ID given to you to register int the app.", fSColor: .black, fSFont: font))
        
        return att
    }
    
    static var initialProps: [String] {
        
        let props = ["Pill Bottle",
                     "Tatto",
                     "Transcripts",
                     "Mortage, Investment or Retirement Report",
                     "Local News Paper",
                     "Bank Statement",
                     "Bill or Receipt",
                     "Condom Box",
                     "Bussiness Card",
                     "Credit Card/Debit Card",
                     "Doctors Prescription",
                     "Letter with Address",
                     "Medical Record",
                     "Pregnancy Test"]
        return props
    }
    
    static var initialInfoText: NSMutableAttributedString {
        let font: UIFont = .systemFont(ofSize: 11, weight: .regular)
        
        let att = NSAttributedString.attributedString(fString: "Thank you for agreeing to participate in this study!In this study, you will use the VizPriv app to take images and short videos of 14 objects that we sent to you. These objects are fabricated to contain private information. Your images and videos will help AI assistive technologies to better identify private information in pictures taken by blind and low vision people and warn them before they share with others. On the next page, we will walk you through the specific steps you need to take to complete the photography tasks.", fSColor: .black, fSFont: font)
        
        
        att.append(NSAttributedString.attributedString(fString: "\n\n Step 1: Grab one object from the box we mailed. Each bag has a braille label and a QR code. You can read the braille label and manually select from the object from the prop list in the app, or you can scan the QR code within the app. The app will then take you to a page to capture and upload pictures and videos of that object.", fSColor: .black, fSFont: font))
        
        att.append(NSAttributedString.attributedString(fString: "\n\n Step 2: Once an object is selected, you will complete four tasks: (1) capture the object in the foreground of an image; (2) capture the object in the background of an image; (3) capture the object in the foreground of a video; (4) capture the object in the background of a video. Instructions for each of these will be given as you go.", fSColor: .black, fSFont: font))
        
        att.append(NSAttributedString.attributedString(fString: "\n\n Step 3: You can review and re-take your photos and videos of any object by re-visiting that object’s page from the prop list.", fSColor: .black, fSFont: font))
        
        att.append(NSAttributedString.attributedString(fString: "\n\n Step 4: We will review your photos and videos, and may ask you to retake, if they contain your personal information, or have other issues. Are you ready to start the tasks?", fSColor: .black, fSFont: font))
        
        return att
    }
}
