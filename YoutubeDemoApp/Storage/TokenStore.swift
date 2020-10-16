//
//  TokenStore.swift
//  YoutubeDemoApp
//
//  Created by clement on 2020-10-14.
//

import Foundation

class TokenStore: TokenProvider {
    
    private var token: String? = .none
    
    func storeToken(token: String) -> Void {
        self.token = token
    }
    
    func retrieveToken() -> String? {
        return self.token
    }
    
}
