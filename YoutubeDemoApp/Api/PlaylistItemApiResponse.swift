//
//  PlaylistItemApiResponse.swift
//  YoutubeDemoApp
//
//  Created by clement on 2020-10-15.
//

import Foundation

struct PlaylistItemApiResponseContentDetails: Decodable {
    let videoId: String
}

struct PlaylistItemApiResponseThumbnail: Decodable {
    let url: String
}

struct PlaylistItemApiResponseSnippet: Decodable {
    let playlistId: String
    let thumbnails: [String:PlaylistItemApiResponseThumbnail]
    let title: String
}

struct PlaylistItemApiResponseItem: Decodable {
    let contentDetails: PlaylistItemApiResponseContentDetails
    let snippet: PlaylistItemApiResponseSnippet
}

struct PlaylistItemApiResponse: Decodable, PaginatedResponse {
    let items: [PlaylistItemApiResponseItem]
    let nextPageToken: String?
}
