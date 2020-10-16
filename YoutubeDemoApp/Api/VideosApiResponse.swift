//
//  VideosApiResponse.swift
//  YoutubeDemoApp
//
//  Created by clement on 2020-10-15.
//

import Foundation

struct VideosApiResponseContentDetails: Decodable {
    let duration: String
}

struct VideosApiResponseSnippet: Decodable {
    let channelTitle: String
}

struct VideosApiResponseItem: Decodable {
    let contentDetails: VideosApiResponseContentDetails
    let id: String
    let snippet: VideosApiResponseSnippet
}

struct VideosApiResponse: Decodable, PaginatedResponse {
    let items: [VideosApiResponseItem]
    let nextPageToken: String?
}
