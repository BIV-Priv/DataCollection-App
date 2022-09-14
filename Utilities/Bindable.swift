//
//  Bindable.swift
//  QRScanner
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            Observer?(value)
        }
    }
    
    private var Observer: ((T?) -> ())?
    
    func bind(observer: @escaping(T?) -> ()) {
        self.Observer = observer
    }
}
