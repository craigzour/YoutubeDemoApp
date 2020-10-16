//
//  PlaylistsProvider.swift
//  YoutubeDemoApp
//
//  Created by clement on 2020-10-14.
//

import Foundation
import RxSwift

protocol PlaylistsApiProvider {
    func requestPlaylists() -> Single<[PlaylistsApiResponse]>
}

protocol PlaylistsDatabaseProvider {
    func savePlaylists(playlists: [Playlist]) -> Completable
    func hasSavedPlaylists() -> Single<Bool>
    func retrievePlaylists() -> Single<[Playlist]>
}

class PlaylistsProvider {
    
    private let api: PlaylistsApiProvider
    private let database: PlaylistsDatabaseProvider
    
    init(api: PlaylistsApiProvider, database: PlaylistsDatabaseProvider) {
        self.api = api
        self.database = database
    }
    
    func retrievePlaylists() -> Single<[Playlist]> {
        return self
            .database
            .hasSavedPlaylists()
            .flatMap { hasSavedPlaylists -> Single<[Playlist]> in
                if hasSavedPlaylists {
                    return self.database.retrievePlaylists()
                } else {
                    return self
                        .api
                        .requestPlaylists()
                        .map { apiResponses in apiResponses.flatMap { $0.toPlaylists() } }
                        .flatMap { self.database.savePlaylists(playlists: $0).andThen(Single.just($0)) }
                }
            }
    }

}

extension PlaylistsApiResponse {
    func toPlaylists() -> [Playlist] {
        return self.items.map { i -> Playlist in
            return Playlist(
                id: i.id,
                thumbnailUrl: i.snippet.thumbnails["default"]!.url,
                title: i.snippet.title,
                numberOfVideos: i.contentDetails.itemCount
            )
        }
    }
}
