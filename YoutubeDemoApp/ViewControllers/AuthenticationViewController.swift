//
//  AuthenticationViewController.swift
//  YoutubeDemoApp
//
//  Created by clement on 2020-10-14.
//

import UIKit
import GoogleSignIn
import RxSwift

class AuthenticationViewController: UIViewController {
    
    private let googleAuthenticator = SharedInstances.sharedInstance.googleAuthenticator
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if googleAuthenticator.hasCachedCredentialsAvailable() {
            print("DEBUG >>> will try to sign in automatically")
            signIn()
        }
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        signIn()
    }
    
    func signIn() -> Void {
        let _ = googleAuthenticator
            .signIn()
            .subscribeOn(MainScheduler.instance)
            .subscribe { result in
                switch result {
                case .success(let token):
                    //print("TOKEN = \(token)")
                    SharedInstances.sharedInstance.tokenStore.storeToken(token: token)
                    self.performSegue(withIdentifier: "moveToPlaylistsView", sender: .none)
                case .error(let error):
                    print("ERROR = \(error)")
                    let alertController = UIAlertController(title: "An error occured", message: "Unable to sign-in", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: .none)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: .none)
                }
            }
    }
}
