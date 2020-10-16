//
//  Database.swift
//  YoutubeDemoApp
//
//  Created by clement on 2020-10-16.
//

import Foundation
import GRDB
import RxGRDB
import RxSwift

class SqliteDatabase: PlaylistsDatabaseProvider, PlaylistItemsDatabaseProvider {
    
    private let databaseQueue: DatabaseQueue
    
    init() {
        let libraryDirectoryUrl = FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
        let dbUrl = libraryDirectoryUrl.appendingPathComponent("youtubeDemoAppDatabase.sqlite")
        self.databaseQueue = try! DatabaseQueue(path: dbUrl.path)
        
        try! self.databaseQueue.write { database in
            try! database.create(table: "playlists", ifNotExists: true, body: { definition in
                definition.column("id", .text).primaryKey()
                definition.column("thumbnailUrl", .text)
                definition.column("title", .text)
                definition.column("numberOfVideos", .integer)
            })
            
            try! database.create(table: "playlistItems", ifNotExists: true, body: { definition in
                definition.column("videoId", .text)
                definition.column("playlistId", .text).indexed()
                definition.column("thumbnailUrl", .text)
                definition.column("title", .text)
                definition.column("author", .text)
                definition.column("duration", .text)
            })
        }
    }
    
    func savePlaylists(playlists: [Playlist]) -> Completable {
        return self
            .databaseQueue
            .rx
            .write { database in playlists.forEach { try! $0.save(database) } }
            .asCompletable()
    }
    
    func hasSavedPlaylists() -> Single<Bool> {
        return self
            .databaseQueue
            .rx
            .read { try! Playlist.fetchCount($0) }
            .map { $0 > 0 }
    }
    
    func retrievePlaylists() -> Single<[Playlist]> {
        return self.databaseQueue.rx.read { try! Playlist.fetchAll($0) }
    }
    
    func savePlaylistItems(playlistItems: [PlaylistItem]) -> Completable {
        return self
            .databaseQueue
            .rx
            .write { database in playlistItems.forEach { try! $0.save(database) } }
            .asCompletable()
    }
    
    func hasSavedPlaylistItems(playlistId: String) -> Single<Bool> {
        return self
            .databaseQueue
            .rx
            .read { try! PlaylistItem.filter(Column("playlistId") == playlistId).fetchCount($0) }
            .map { $0 > 0 }
    }
    
    func retrievePlaylistItems(playlistId: String) -> Single<[PlaylistItem]> {
        return self.databaseQueue.rx.read { try! PlaylistItem.filter(Column("playlistId") == playlistId).fetchAll($0) }
    }
    
}

extension Playlist: TableRecord, PersistableRecord, FetchableRecord {
    static let databaseTableName = "playlists"
    
    func encode(to container: inout PersistenceContainer) {
        container["id"] = self.id
        container["thumbnailUrl"] = self.thumbnailUrl
        container["title"] = self.title
        container["numberOfVideos"] = self.numberOfVideos
    }
    
    init(row: Row) {
        self.id = row["id"]
        self.thumbnailUrl = row["thumbnailUrl"]
        self.title = row["title"]
        self.numberOfVideos = row["numberOfVideos"]
    }
}

extension PlaylistItem: TableRecord, PersistableRecord, FetchableRecord {
    static let databaseTableName = "playlistItems"
    
    func encode(to container: inout PersistenceContainer) {
        container["playlistId"] = self.playlistId
        container["videoId"] = self.videoId
        container["thumbnailUrl"] = self.thumbnailUrl
        container["title"] = self.title
        container["author"] = self.author
        container["duration"] = self.duration
    }
    
    init(row: Row) {
        self.playlistId = row["playlistId"]
        self.videoId = row["videoId"]
        self.thumbnailUrl = row["thumbnailUrl"]
        self.title = row["title"]
        self.author = row["author"]
        self.duration = row["duration"]
    }
}
