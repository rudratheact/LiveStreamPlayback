//
//  LiveStreamViewController.swift
//  LiveStreamPlayback
//
//  Created by rudra misra on 19/12/24.
//

import UIKit
import AVKit

class LiveStreamViewController: UIViewController {

    // MARK: UI components
    private var collectionView: UICollectionView! // videos collection view
    
    private let viewModel = VideoViewModel() // Instance of View Model

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchVideos()
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
        collectionView.contentInsetAdjustmentBehavior = .never
        view.addSubview(collectionView)
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
}

// MARK: - Collection View Data Source and Delegate
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
