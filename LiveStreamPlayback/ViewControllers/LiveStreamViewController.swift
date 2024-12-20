//
//  LiveStreamViewController.swift
//  LiveStreamPlayback
//
//  Created by rudra misra on 19/12/24.
//

import UIKit
import AVKit

class LiveStreamViewController: UIViewController {

    private var collectionView: UICollectionView! // videos collection view
    private var commentTableView = UITableView() // comments table view

    private let viewModel = VideoViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
        fetchVideos()
        fetchComments()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.identifier)
        collectionView.isPagingEnabled = true
        view.addSubview(collectionView)
    }
    
    func setupTableView() {
        commentTableView.translatesAutoresizingMaskIntoConstraints = false
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.separatorStyle = .none // Remove default separators
        commentTableView.backgroundColor = .clear // Transparent background
        view.addSubview(commentTableView)
        
        // Constraints for the table view
        NSLayoutConstraint.activate([
            commentTableView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -250),
            commentTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            commentTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            commentTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
        
        // Register the custom cell
        commentTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "CommentCell")
    }

    // MARK: load videos
    private func fetchVideos() {
        viewModel.fetchVideos { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print("Error fetching videos: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: load ocmments
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
}

extension LiveStreamViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.identifier, for: indexPath) as! VideoCell
        cell.video = viewModel.videos[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let videoCell = cell as? VideoCell else { return }
        videoCell.startPlaying()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let videoCell = cell as? VideoCell else { return }
        videoCell.stopPlaying()
    }

}

// MARK: - Table View Data Source and Delegate
extension LiveStreamViewController: UITableViewDelegate, UITableViewDataSource {
    
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
