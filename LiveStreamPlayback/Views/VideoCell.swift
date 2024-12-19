//
//  VideoCell.swift
//  LiveStreamPlayback
//
//  Created by rudra misra on 19/12/24.
//

import UIKit
import AVKit

class VideoCell: UICollectionViewCell {
    static let identifier = "VideoCell"
    
    var video: Video? {
        didSet {
            setupPlayer()
        }
    }
    
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    
    private let videoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(videoContainerView)
        videoContainerView.frame = contentView.frame
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlayer() {
        guard let video = video else { return }
        guard let url = URL(string: video.video ?? "") else { return }
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoContainerView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        videoContainerView.layer.addSublayer(playerLayer!)
        
        // Tap on video
        setupTapGesture()
        
        player?.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    private func setupTapGesture() {
        // Setup single tap gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        videoContainerView.addGestureRecognizer(tapGestureRecognizer)
        
        // Setup double tap gesture recognizer
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2 // Detect double taps
        videoContainerView.addGestureRecognizer(doubleTapGestureRecognizer)
        videoContainerView.isUserInteractionEnabled = true // Enable user interaction
    }
    
    // Handle double tap action
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        handleTap()
        triggerHeartAnimation()
    }
    
    // MARK: Video Player controller
    @objc private func playerDidFinishPlaying() {
        player?.seek(to: .zero)
        player?.play()
    }
    
    @objc func handleTap() {
        if player?.rate == 0 {
            startPlaying()
        } else {
            stopPlaying()
        }
    }
    
    func startPlaying() {
        player?.play()
    }
    
    func stopPlaying() {
        player?.pause()
    }
    
    // MARK: floating heart animation
    private func triggerHeartAnimation() {
        let heartImageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        heartImageView.tintColor = .red
        heartImageView.frame = CGRect(x: videoContainerView.bounds.midX - 30, y: videoContainerView.bounds.midY - 30, width: 60, height: 60)
        
        videoContainerView.addSubview(heartImageView)
        UIView.animate(withDuration: 0.6, animations: {
            heartImageView.alpha = 0
            heartImageView.transform = CGAffineTransform(translationX: 0, y: -100).scaledBy(x: 2, y: 2)
        }) { _ in
            heartImageView.removeFromSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }
}
