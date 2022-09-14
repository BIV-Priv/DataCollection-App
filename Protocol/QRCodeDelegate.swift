//
//  QRCodeDelegate.swift
//  QRScanner


import Foundation

protocol QRCodeDelegate: AnyObject {
    func found(string: String)
}
