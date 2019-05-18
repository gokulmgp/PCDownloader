//
//  Model.swift
//  SampleFeed
//
//  Created by Prasad on 18/05/19.
//  Copyright © 2019 Prasad. All rights reserved.
//

import Foundation
import PCDownloader

struct Item : Codable {
    
    struct urls : Codable
    {
        let raw: String?
        
        let full: String?
        
        let regular: String?
        
        let small: String?
        
        let thumb: String?
    }
    
    struct user:Codable {
        
        struct profile_image:Codable
        {
            let small: String?
            
            let medium: String?
            
            let large: String?
            
        }
        
        let username: String?
        
        let name: String?
        
        let id: String?
        
        let profile_image: profile_image
        
    }
    
    let urls: urls
    
    let user: user
    
    let id: String?
    
    let width:Int
    
    let height:Int
    
    let color:String?
    
    enum CodingKeys: String, CodingKey {
        // include only those that you want to decode/encode
        case urls, user, id, width, height, color
        
    }
    
    var enableDownloading:Bool = true
    
}


class Model
{
    var items:Array<Item?>?
    
    private var pcDownloader:PCDownloader
    
    init(downloader:PCDownloader)
    {
        self.items = []
        
        self.pcDownloader = downloader
        
    }
    
    func makeApiCall(completion:@escaping (Data?, Bool?) -> Void) -> Void
    {
        
        let baseURL = URL(string: Bundle.main.apiBaseUrl())!
        
        let _ = pcDownloader.dataWithURL(baseURL) { (data) in
            if (data != nil)
            {
                let decoder = JSONDecoder()
                
                let items = try! decoder.decode(Array<Item?>.self, from: data!)
                
                self.items = items
                
                
                completion(data,true)
                
            }
            else
            {
                completion(data,false)
            }
        }
        
    }
}
