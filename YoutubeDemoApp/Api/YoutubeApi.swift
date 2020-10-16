//
//  YoutubeApi.swift
//  YoutubeDemoApp
//
//  Created by clement on 2020-10-15.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire

protocol TokenProvider {
    func retrieveToken() -> String?
}

protocol PaginatedResponse: Decodable {
    var nextPageToken: String? { get }
}

enum YoutubeApiRequestType {
    case playlists
    case playlistItems(playlistId: String)
    case videos(videoIds: [String])
    
    func url() -> String {
        switch self {
        case .playlists:
            return "https://www.googleapis.com/youtube/v3/playlists"
        case .playlistItems(_):
            return "https://www.googleapis.com/youtube/v3/playlistItems"
        case .videos(_):
            return "https://www.googleapis.com/youtube/v3/videos"
        }
    }
}

class YoutubeApi: PlaylistsApiProvider, PlaylistItemsApiProvider {
    
    private let session: Session
    private let tokenProvider: TokenProvider
    
    init(session: Session, tokenProvider: TokenProvider) {
        self.session = session
        self.tokenProvider = tokenProvider
    }
    
    func requestPlaylists() -> Single<[PlaylistsApiResponse]> {
        return paginatedRequest(requestType: .playlists).toArray()
    }
    
    func requestPlaylistItems(playlistId: String) -> Single<[PlaylistItemApiResponse]> {
        return paginatedRequest(requestType: .playlistItems(playlistId: playlistId)).toArray()
    }
    
    func requestVideos(videoIds: [String]) -> Single<[VideosApiResponse]> {
        return paginatedRequest(requestType: .videos(videoIds: videoIds)).toArray()
    }
    
    private func paginatedRequest<T: PaginatedResponse>(
        requestType: YoutubeApiRequestType,
        maxResults: UInt = 2,
        nextPageToken: String? = .none
    ) -> Observable<T> {
        return self
            .request(requestType: requestType, nextPageToken: nextPageToken)
            .flatMap { (previousResponse: T) -> Observable<T> in
                if let pageToken = previousResponse.nextPageToken {
                    return self.paginatedRequest(requestType: requestType, nextPageToken: pageToken).concat(Observable.from([previousResponse]))
                } else {
                    return Observable.empty().concat(Observable.from([previousResponse]))
                }
            }
    }
    
    private func request<T: PaginatedResponse>(requestType: YoutubeApiRequestType, maxResults: UInt = 2, nextPageToken: String? = .none) -> Observable<T> {
        var parameters: [String:Any] = [:]
        
        parameters["part"] = "snippet,contentDetails"
        parameters["maxResults"] = maxResults
        
        switch requestType {
        case .playlists:
            parameters["mine"] = true
        case .playlistItems(let playlistId):
            parameters["playlistId"] = playlistId
        case .videos(let videoIds):
            parameters["id"] = videoIds.joined(separator: ",")
        }
        
        if nextPageToken != .none {
            parameters["pageToken"] = nextPageToken
        }
        
        return self
            .session
            .rx
            .decodable(
                .get,
                requestType.url(),
                parameters: parameters,
                headers: ["Authorization" : "Bearer " + self.tokenProvider.retrieveToken()!]
            )
    }
    
}
