//
//  ANotification.swift
//  QRScanner
//

import Foundation
import UIKit

class UNotification {
    public static func post(announcment: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: announcment)
        }
    }
}
