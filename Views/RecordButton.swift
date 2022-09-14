//
//  RecordButton.swift
//  QRScanner
//

import UIKit


class RecordButton: UIButton {
    
    //MARK: - Properties
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = height / 2
    }
    
    enum State {
        case recording
        case notRecording
    }
    
    public func toggle(for state: State) {
        switch state {
        case .recording:
            backgroundColor = .systemRed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIAccessibility.post(notification: .announcement, argument: "Recording")
            }
        case .notRecording:
            backgroundColor = .black
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIAccessibility.post(notification: .announcement, argument: "Recording stopped")
            }
            
        }
    }
}
