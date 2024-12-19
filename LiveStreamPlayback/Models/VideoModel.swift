//
//  VideoModel.swift
//  LiveStreamPlayback
//
//  Created by rudra misra on 19/12/24.
//

import Foundation

struct Video: Decodable {
    let id: Int?
    let userID: Int?
    let username: String?
    let profilePicURL: String?
    let description: String?
    let topic: String?
    let viewers: Int?
    let likes: Int?
    let video: String?
    let thumbnailURL: String?
}

struct Comment: Decodable {
    let id: Int?
    let username: String?
    let picURL: String?
    let comment: String?
}
