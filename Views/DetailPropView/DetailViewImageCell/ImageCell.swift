//
//  ImageCell.swift
//  QRScanner
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    public let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .gray
        return iv
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.fillSuperview()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("Failed to init image cell")
    }
}
