//
//  DetailPropHeaderView.swift
//  QRScanner
//

import UIKit

class DetailPropHeaderView: UICollectionReusableView {
        
    //MARK: - Properties
    
    weak var delegate: DetailPropHeaderDelegate?
    
    let segmentedControl: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["Forground Image", "BackgroundImage"])
        seg.selectedSegmentIndex = 0
        seg.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        return seg
    }()
    
    @objc
    func handleSegmentChange() {
        delegate?.selectImage(for: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(segmentedControl)
        segmentedControl.center(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
