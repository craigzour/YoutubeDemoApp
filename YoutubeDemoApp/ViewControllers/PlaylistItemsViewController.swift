//
//  PlaylistItemsViewController.swift
//  YoutubeDemoApp
//
//  Created by clement on 2020-10-15.
//

import UIKit
import RxSwift

class PlaylistItemTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var authorTextLabel: UILabel!
    @IBOutlet weak var durationTextLabel: UILabel!
}

class PlaylistItemsViewController: UITableViewController {
    
    @IBOutlet weak var currentPlaylistThumbnailImageView: UIImageView!
    @IBOutlet weak var currentPlaylistTitleTextLabel: UILabel!
    @IBOutlet weak var currentPlaylistNumberOfVideosTextLabel: UILabel!
    
    private var playlistItems: [PlaylistItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let selectedPlaylist = SharedInstances.sharedInstance.selectedPlaylist!
        
        self.currentPlaylistThumbnailImageView.load(url: URL(string: selectedPlaylist.thumbnailUrl)!)
        self.currentPlaylistTitleTextLabel.text = selectedPlaylist.title
        self.currentPlaylistNumberOfVideosTextLabel.text = "Number of videos: \(selectedPlaylist.numberOfVideos)"
        
        let _ = SharedInstances
            .sharedInstance
            .playlistItemsProvider
            .retrievePlaylistItems(playlistId: selectedPlaylist.id)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onSuccess: { playlistItems in
                self.playlistItems = playlistItems
                self.tableView.reloadData()
            }, onError: { error in
                let alertController = UIAlertController(title: "An error occured", message: "Unable to retrieve playlist items", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: .none)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: .none)
            })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistItemCellIdentifier", for: indexPath) as! PlaylistItemTableViewCell
        
        let playlistItem = self.playlistItems[indexPath.row]
        cell.thumbnailImageView?.load(url: URL(string: playlistItem.thumbnailUrl)!)
        cell.titleTextLabel?.text = playlistItem.title
        cell.authorTextLabel.text = playlistItem.author
        cell.durationTextLabel.text = playlistItem.duration
        
        return cell
    }
    
}
