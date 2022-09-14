//
//  VideoCell.swift
//  QRScanner
//

import UIKit
import AATools
import AVFoundation

class VideoCell: UICollectionViewCell {
    
    var url: URL? {
        didSet {
            setupVideo()
        }
    }
    
    var isPlaying = false
    
    var previewLayer = AVPlayerLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupPlayGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    private func setupPlayGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapPlay))
        contentView.addGestureRecognizer(tap)
    }
    
    @objc
    private func handleTapPlay() {
        Debug.log(message: "did call", variable: #function)
        if isPlaying {
            previewLayer.player?.pause()
            isPlaying.toggle()
        } else {
            previewLayer.player?.seek(to: CMTime.zero)
            previewLayer.player?.play()
            isPlaying.toggle()
        }
    }
    
    private func setupVideo() {
        
        guard let url = url else {
            return
        }
        
        let player = AVPlayer(url: url)
        previewLayer = AVPlayerLayer(player: player)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = contentView.bounds
        contentView.layer.addSublayer(previewLayer)
        previewLayer.player?.play()
    }
}
