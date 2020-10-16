//
//  SharedInstances.swift
//  YoutubeDemoApp
//
//  Created by clement on 2020-10-14.
//

import Foundation
import Alamofire

class SharedInstances {
    
    static let sharedInstance = SharedInstances()
    
    let googleAuthenticator: GoogleAuthenticator
    let tokenStore: TokenStore
    
    let playlistsProvider: PlaylistsProvider
    let playlistItemsProvider: PlaylistItemsProvider
    
    var selectedPlaylist: Playlist? = .none
    
    private init() {
        self.googleAuthenticator = GoogleAuthenticator()
        self.tokenStore = TokenStore()
        
        let session = Session.default
        let youtubeApi = YoutubeApi(session: session, tokenProvider: self.tokenStore)
        let database = SqliteDatabase()
        
        self.playlistsProvider = PlaylistsProvider(api: youtubeApi, database: database)
        self.playlistItemsProvider = PlaylistItemsProvider(api: youtubeApi, database: database)
    }
    
}
