//
//  RootViewController.swift
//  QRScanner
//


import UIKit

class RootViewController {
    public static var rootViewController: UIViewController {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let rootViewController = SplashController()
        
        return rootViewController
    }
}
