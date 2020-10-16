//
//  PlaylistItemsProvider.swift
//  YoutubeDemoApp
//
//  Created by clement on 2020-10-15.
//

import Foundation
import RxSwift

protocol PlaylistItemsApiProvider {
    func requestPlaylistItems(playlistId: String) -> Single<[PlaylistItemApiResponse]>
    func requestVideos(videoIds: [String]) -> Single<[VideosApiResponse]>
}

protocol PlaylistItemsDatabaseProvider {
    func savePlaylistItems(playlistItems: [PlaylistItem]) -> Completable
    func hasSavedPlaylistItems(playlistId: String) -> Single<Bool>
    func retrievePlaylistItems(playlistId: String) -> Single<[PlaylistItem]>
}

class PlaylistItemsProvider {
    
    private let api: PlaylistItemsApiProvider
    private let database: PlaylistItemsDatabaseProvider
    
    init(api: PlaylistItemsApiProvider, database: PlaylistItemsDatabaseProvider) {
        self.api = api
        self.database = database
    }
    
    func retrievePlaylistItems(playlistId: String) -> Single<[PlaylistItem]> {
        return self.database.hasSavedPlaylistItems(playlistId: playlistId).flatMap { hasSavedPlaylistItems -> Single<[PlaylistItem]> in
            if hasSavedPlaylistItems {
                return self.database.retrievePlaylistItems(playlistId: playlistId)
            } else {
                return self
                    .api
                    .requestPlaylistItems(playlistId: playlistId)
                    .flatMap { apiResponses -> Single<[PlaylistItem]> in
                        let videoIds = apiResponses.flatMap { $0.items.map { $0.contentDetails.videoId } }
                        return self.api.requestVideos(videoIds: videoIds).map { videosApiResponse -> [PlaylistItem] in
                            let videosMetadataForId = videosApiResponse.flatMap { $0.items }.toDictionary(with: { $0.id })
                            return apiResponses.flatMap { $0.toPlaylistItems(metadata: videosMetadataForId) }
                        }
                    }
                    .flatMap { self.database.savePlaylistItems(playlistItems: $0).andThen(Single.just($0)) }
            }
        }
    }

}

extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}

extension PlaylistItemApiResponse {
    func toPlaylistItems(metadata: [String:VideosApiResponseItem]) -> [PlaylistItem] {
        return self.items.map { i -> PlaylistItem in
            return PlaylistItem(
                videoId: i.contentDetails.videoId,
                playlistId: i.snippet.playlistId,
                thumbnailUrl: i.snippet.thumbnails["default"]!.url,
                title: i.snippet.title,
                author: metadata[i.contentDetails.videoId]!.snippet.channelTitle,
                duration: parseDuration(videoDuration: metadata[i.contentDetails.videoId]!.contentDetails.duration)
            )
        }
    }
}

func parseDuration(videoDuration: String?) -> String {
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    
    if let videoDuration = videoDuration {
        var lastIndex = videoDuration.startIndex
        
        if let indexT = videoDuration.firstIndex(of: "T") {
            lastIndex = videoDuration.index(after: indexT)
            
            if let indexH = videoDuration.firstIndex(of: "H") {
                let hrs = String(videoDuration[lastIndex..<indexT])
                hours = Int(hrs) ?? 0
                lastIndex = videoDuration.index(after: indexH)
            }
            
            if let indexM = videoDuration.firstIndex(of: "M") {
                let min = String(videoDuration[lastIndex..<indexM])
                minutes = Int(min) ?? 0
                lastIndex = videoDuration.index(after: indexM)
            }
            
            if let indexS = videoDuration.firstIndex(of: "S") {
                let sec = String(videoDuration[lastIndex..<indexS])
                seconds = Int(sec) ?? 0
            }
        }
    }
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}
