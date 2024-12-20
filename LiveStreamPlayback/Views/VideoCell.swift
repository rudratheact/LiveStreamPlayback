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
    private var commentTableView = UITableView() // comments table view

    let profileImageView = UIImageView() // User profile image
    let nameLabel = UILabel() // User's name
    let likesLabel = UILabel() // Likes count
    let viewsLabel = UILabel() // Views count
    let typeLabel = UILabel() // vedio category or type
    
    private let viewModel = VideoViewModel() // Instance of View Model
    
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
        
        setupTableView()
        setupUIs()
        updateUI(video: video)
        fetchComments()
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
    
    // Setup TableView for comments
    func setupTableView() {
        commentTableView.translatesAutoresizingMaskIntoConstraints = false
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.separatorStyle = .none // Remove default separators
        commentTableView.backgroundColor = .clear // Transparent background
        self.addSubview(commentTableView)
        
        // Constraints for the table view
        NSLayoutConstraint.activate([
            commentTableView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -250),
            commentTableView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            commentTableView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            commentTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
        
        // Register the custom cell
        commentTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "CommentCell")
    }
    
    // Setup other UI components
    func setupUIs() {
        // Profile image setup
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 15
        profileImageView.clipsToBounds = true
        self.addSubview(profileImageView)
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill") // Default image
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50),
            profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Name label setup
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.textColor = .white
        self.addSubview(nameLabel)
        nameLabel.text = "Unknown"
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 16)
        ])
        
        // Likes label setup
        likesLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(likesLabel)
        likesLabel.textColor = .lightGray
        likesLabel.font = UIFont.systemFont(ofSize: 15)
        likesLabel.text = "🤍 1234"
        
        NSLayoutConstraint.activate([
            likesLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            likesLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16)
        ])
        
        // Views label setup
        viewsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(viewsLabel)
        viewsLabel.textColor = .lightGray
        viewsLabel.font = UIFont.systemFont(ofSize: 15)
        viewsLabel.text = "🔲 234556"
        
        NSLayoutConstraint.activate([
            viewsLabel.topAnchor.constraint(equalTo: likesLabel.bottomAnchor, constant: 8),
            viewsLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16)
        ])
        
        // Type label setup
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(typeLabel)
        typeLabel.textColor = .white
        typeLabel.font = UIFont.systemFont(ofSize: 15)
        typeLabel.text = "Unknown"
        
        NSLayoutConstraint.activate([
            typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            typeLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10)
        ])
    }
    
    // change UI values as per the videos
    func updateUI(video: Video) {
        nameLabel.text = video.username
        viewsLabel.text = "🔲 \(video.viewers ?? 0)"
        likesLabel.text = "🤍 \(video.likes ?? 0)"
        typeLabel.text = "⭐️ \(video.topic ?? "")"
        getImageAndShow(urlString: video.profilePicURL ?? "")
    }
    
    // Download image file and assign to the image view
    func getImageAndShow(urlString: String) {
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
    
    // MARK: load comments
    private func fetchComments() {
        viewModel.fetchComments { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.commentTableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching videos: \(error.localizedDescription)")
            }
        }
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

// MARK: - Table View Data Source and Delegate
extension VideoCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        let comment = viewModel.comments[indexPath.row]
        // Configure the cell with the comment data
        cell.configure(with: comment)
        
        return cell
    }
}
