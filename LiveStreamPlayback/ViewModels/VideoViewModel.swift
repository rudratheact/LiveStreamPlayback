//
//  VideoViewModel.swift
//  LiveStreamPlayback
//
//  Created by rudra misra on 19/12/24.
//

import Foundation

class VideoViewModel {
    var videos: [Video] = []
    var comments: [Comment] = []

    func fetchVideos(completion: @escaping (Result<[Video], Error>) -> Void) {
        if let filePath = Bundle.main.path(forResource: "video_data", ofType: "json") {
            let url = URL(fileURLWithPath: filePath)
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NSError(domain: "data error", code: 0)))
                    return
                }
                do {
                    let videoResponse = try JSONDecoder().decode([String: [Video]].self, from: data)
                    self.videos = videoResponse["videos"] ?? []
                    completion(.success(self.videos))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }

    func fetchComments(completion: @escaping (Result<[Comment], Error>) -> Void) {
        if let filePath = Bundle.main.path(forResource: "comments_data", ofType: "json") {
            let url = URL(fileURLWithPath: filePath)
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NSError(domain: "data error", code: 0)))
                    return
                }
                do {
                    let commentResponse = try JSONDecoder().decode([String: [Comment]].self, from: data)
                    self.comments = commentResponse["comments"] ?? []
                    completion(.success(self.comments))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
}
