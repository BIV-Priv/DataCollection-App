//
//  DetailViewVideoCell.swift
//  QRScanner
//

import UIKit
import AVFoundation
import AATools

fileprivate let cellIdentifier = "videoCell"

class DetailViewVideoCell: UICollectionViewCell {
    
    //MARK: - Properites
    enum VideoType: Int, CaseIterable {
        case foreground
        case background
    }
    
    var viewModel: DetailPropViewModel! {
        didSet {
            guard let viewModel = viewModel else {
                 return
            }
            
            if viewModel.selectedImage == 0 {
                videoCollectionView.scrollToItem(at: IndexPath(row: viewModel.selectedImage, section: 0), at: .left, animated: true)
            } else {
                videoCollectionView.scrollToItem(at: IndexPath(row: viewModel.selectedImage, section: 0), at: .right, animated: true)
            }
        }
    }
    
    let segmentedControl: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["Foreground Video", "Background Video"])
        seg.selectedSegmentIndex = 0
        seg.setHeight(50)
        seg.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        return seg
    }()
    
    @objc
    func handleSegmentChange(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            videoCollectionView.isPagingEnabled = false
            videoCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
            videoCollectionView.isPagingEnabled = true
        } else {
            videoCollectionView.isPagingEnabled = false
            videoCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .right, animated: true)
            videoCollectionView.isPagingEnabled = true
        }
    }
    
    var player: AVPlayer?
    private var playerDidFinishObserver: NSObjectProtocol?
    
    private lazy var videoCollectionView: UICollectionView = {
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
        segmentedControl.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0)
        
        self.contentView.addSubview(videoCollectionView)
        videoCollectionView.anchor(top: segmentedControl.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
        
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
        videoCollectionView.register(VideoCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
}

//MARK: - UICollectionViewDataSource
extension DetailViewVideoCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! VideoCell
        
        switch VideoType(rawValue: indexPath.row) {
        case .foreground:
            cell.url = viewModel.prop.foregroundVideo
        case .background:
            cell.url = viewModel.prop.backgroundVideo
        case .none:
            break
        }
        
        return cell
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension DetailViewVideoCell: UICollectionViewDelegateFlowLayout {
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


