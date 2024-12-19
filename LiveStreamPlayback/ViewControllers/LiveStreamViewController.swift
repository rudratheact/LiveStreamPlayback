//
//  LiveStreamViewController.swift
//  LiveStreamPlayback
//
//  Created by rudra misra on 19/12/24.
//

import UIKit
import AVKit

class LiveStreamViewController: UIViewController {

    private var collectionView: UICollectionView!
    private let viewModel = VideoViewModel()

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
        view.addSubview(collectionView)
    }

    private func fetchVideos() {
        viewModel.fetchVideos { result in
            switch result {
            case .success(let videos):
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
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

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Logic to track which video is visible and trigger actions
    }
}
