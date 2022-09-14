//
//  DetailViewImageCell.swift
//  QRScanner
//

import UIKit
import AATools

fileprivate let cellIdentifier = "imageCell"

class DetailPropImageCell: UICollectionViewCell {
    
    //MARK: - Properties
    var viewModel: DetailPropViewModel! {
        didSet {
            guard let viewModel = viewModel else {
                 return
            }
            
            if viewModel.selectedImage == 0 {
                imageCollectionView.scrollToItem(at: IndexPath(row: viewModel.selectedImage, section: 0), at: .left, animated: true)
            } else {
                imageCollectionView.scrollToItem(at: IndexPath(row: viewModel.selectedImage, section: 0), at: .right, animated: true)
            }
        }
    }
    
    enum ImageType: Int, CaseIterable {
        case foreground
        case background
    }
    
    let segmentedControl: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["Foreground Image", "Background Image"])
        seg.selectedSegmentIndex = 0
        seg.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        return seg
    }()
    
    @objc
    func handleSegmentChange(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            imageCollectionView.isPagingEnabled = false
            imageCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
            imageCollectionView.isPagingEnabled = true
        } else {
            imageCollectionView.isPagingEnabled = false
            imageCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .right, animated: true)
            imageCollectionView.isPagingEnabled = true
        }
    }
    
    private lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false
        return cv
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(segmentedControl)
        segmentedControl.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, height: 50)
        
        self.contentView.addSubview(imageCollectionView)
        imageCollectionView.anchor(top: segmentedControl.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
        
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    //MARK: - Helpers
    private func setupCollectionView() {
        imageCollectionView.register(ImageCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
}

//MARK: - UICollectionViewDataSource
extension DetailPropImageCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ImageCell
        
        switch ImageType(rawValue: indexPath.row) {
        case .foreground:
            cell.imageView.image = viewModel.prop.foregroundImage
        case .background:
            cell.imageView.image = viewModel.prop.backgroundImage
        case .none:
            break
        }
        
        return cell
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension DetailPropImageCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        .init(width: contentView.width, height: contentView.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}


