//
//  PlaylistsViewController.swift
//  YoutubeDemoApp
//
//  Created by clement on 2020-10-14.
//

import UIKit
import RxSwift

class PlaylistTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var numberOfVideosTextLabel: UILabel!
}

class PlaylistsViewController: UITableViewController {
    
    private var playlists: [Playlist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let _ = SharedInstances
            .sharedInstance
            .playlistsProvider
            .retrievePlaylists()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onSuccess: { playlists in
                self.playlists = playlists
                self.tableView.reloadData()
            }, onError: { error in
                let alertController = UIAlertController(title: "An error occured", message: "Unable to retrieve playlists", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: .none)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: .none)
            })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCellIdentifier", for: indexPath) as! PlaylistTableViewCell
        
        let playlist = self.playlists[indexPath.row]
        cell.thumbnailImageView?.load(url: URL(string: playlist.thumbnailUrl)!)
        cell.titleTextLabel?.text = playlist.title
        cell.numberOfVideosTextLabel?.text = "Number of videos: \(playlist.numberOfVideos)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SharedInstances.sharedInstance.selectedPlaylist = self.playlists[indexPath.row]
        self.performSegue(withIdentifier: "moveToPlaylistItemsView", sender: .none)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if parent == nil {
            debugPrint("will sign out")
            SharedInstances.sharedInstance.googleAuthenticator.signOut()
        }
    }
    
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
