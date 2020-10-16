//
//  GoogleAuthenticator.swift
//  YoutubeDemoApp
//
//  Created by clement on 2020-10-14.
//

import Foundation
import GoogleSignIn
import RxSwift

enum AuthenticationResult {
    case Success(token: String)
    case Failure(error: Error)
}

class GoogleAuthenticator {
    
    private let authenticationResult = PublishSubject<AuthenticationResult>()
    
    func hasCachedCredentialsAvailable() -> Bool {
        return GIDSignIn.sharedInstance().hasPreviousSignIn()
    }
    
    func signIn() -> Single<String> {
        return Single.create { completable in
            let disposable = self.authenticationResult.first().subscribe { result in
                switch result {
                case .success(let value):
                    switch value! {
                    case .Success(let token):
                        completable(.success(token))
                    case .Failure(let error):
                        completable(.error(error))
                    }
                default:
                    break
                }
            }
            
            if GIDSignIn.sharedInstance().hasPreviousSignIn() {
                GIDSignIn.sharedInstance().restorePreviousSignIn()
            } else {
                GIDSignIn.sharedInstance().signIn()
            }
            
            return Disposables.create([disposable])
        }
    }
    
    func signOut() -> Void {
        GIDSignIn.sharedInstance().signOut()
    }
    
    func publishAuthenticationResult(authenticationResult: AuthenticationResult) -> Void {
        self.authenticationResult.onNext(authenticationResult)
    }
    
}
