//
//  DetailPropDelegate.swift
//  QRScanner


import Foundation

protocol DetailPropDelegate: AnyObject {
    func edit(prop: PropViewModel, for media: MediaType)
}
