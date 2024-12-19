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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPlayer() {
        guard let video = video else { return }
        guard let url = URL(string: video.videoURL ?? "") else { return }

        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoContainerView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        videoContainerView.layer.addSublayer(playerLayer!)

        player?.play()
        player?.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }

    @objc private func playerDidFinishPlaying() {
        player?.seek(to: .zero)
        player?.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }
}
