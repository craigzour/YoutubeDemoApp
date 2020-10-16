//
//  PlaylistsApiResponse.swift
//  YoutubeDemoApp
//
//  Created by clement on 2020-10-15.
//

import Foundation

struct PlaylistsApiResponseContentDetails: Decodable {
    let itemCount: UInt
}

struct PlaylistsApiResponseThumbnail: Decodable {
    let url: String
}

struct PlaylistsApiResponseSnippet: Decodable {
    let thumbnails: [String:PlaylistsApiResponseThumbnail]
    let title: String
}

struct PlaylistsApiResponseItem: Decodable {
    let contentDetails: PlaylistsApiResponseContentDetails
    let id: String
    let snippet: PlaylistsApiResponseSnippet
}

struct PlaylistsApiResponse: Decodable, PaginatedResponse {
    let items: [PlaylistsApiResponseItem]
    let nextPageToken: String?
}
