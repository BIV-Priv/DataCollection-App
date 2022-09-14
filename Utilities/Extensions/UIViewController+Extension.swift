//
//  UIViewController+Extension.swift
//  QRScanner
//

import Foundation
import UIKit
import JGProgressHUD

extension UIViewController {
    public static let progressHud = JGProgressHUD(style: .dark)

    public func showProgressHud(_ show: Bool) {
        
        if show {
            UIViewController.progressHud.vibrancyEnabled = true
            if arc4random_uniform(2) == 0 {
                UIViewController.progressHud.indicatorView = JGProgressHUDPieIndicatorView()
            }
            else {
                UIViewController.progressHud.indicatorView = JGProgressHUDRingIndicatorView()
            }
            UIViewController.progressHud.detailTextLabel.text = "0% Complete"
            UIViewController.progressHud.textLabel.text = "Uploading..."
            UIViewController.progressHud.show(in: self.view)

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                self.incrementHUD(progress: 0)
            }
        } else {
            UIViewController.progressHud.dismiss(animated: true)
        }
    }

    func incrementHUD(progress: Double) {
        UIViewController.progressHud.detailTextLabel.text = "\((progress * 100).format(f: "%.0f"))% Complete"
        UIViewController.progressHud.progress = Float(progress)
        if progress == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                UIView.animate(withDuration: 0.1, animations: {
                    UIViewController.progressHud.textLabel.text = "Success"
                    UIViewController.progressHud.detailTextLabel.text = nil
                    UIViewController.progressHud.indicatorView = JGProgressHUDSuccessIndicatorView()
                })

                UIViewController.progressHud.dismiss(afterDelay: 1.0)
            }
        }
    }
}
