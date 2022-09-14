//
//  NavigationDelegate.swift
//  QRScanner


import Foundation

protocol NavigationDelegate: AnyObject {
    func dismiss()
    func popViewController()
    func showHome(option: InitialOptionType)
    func showSelectInitialOption()
}

extension NavigationDelegate {
    func dismiss() {
        
    }
    
    func popViewController() {
        
    }
    
    func showHome(option: InitialOptionType) {
        
    }
    
    func showSelectInitialOption() {
        
    }
}
