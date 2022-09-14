//
//  DetailPropViewModel.swift
//  QRScanner
//

import Foundation

class DetailPropViewModel {
    internal init(prop: PropViewModel, selectedImage: Int) {
        self.prop = prop
        self.selectedImage = selectedImage
    }
    
    let prop: PropViewModel
    let selectedImage: Int
}
