//
//  ServiceConfiguration.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation

class ServiceConfiguration {
    //static let serverName = "localhost"
    
    static let serverName2 = "localhost"
    static let port2 = 3000
    
    static let serverName3 = "jjhaudio.hengdianworld.com"
    static let port3 = 80
    
    static let serverName4 = "www.jinjunhang.com"
    static let port4 = 3001
    
    
    static var serverName: String {
        get {
            return serverName3
        }
    }
    
    static var port: Int {
        get {
            return port3
        }
    }
    
    static let GetAlbumsUrl = "http://\(serverName):\(port)/albums"
    
    static let ImageUrlPrefix = "http://\(serverName):\(port)/"
    
    static func GetAlbumSongsUrl(id: String) -> String {
        return "http://\(serverName):\(port)/album/\(id)/songs"
    }
    
    static func GetSongUrl(urlSuffix: String) -> String {
        return "http://\(serverName):\(port)/\(urlSuffix)"
    }
    
    static func GetAlbumImageUrl(urlSuffix: String) -> String {
        return "\(ServiceConfiguration.ImageUrlPrefix)/\(urlSuffix)"
    }
}
