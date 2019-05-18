//
//  PCDownloader.swift
//  ProjectC
//
//  Created by Prasad on 16/05/19.
//  Copyright © 2019 Prasad. All rights reserved.
//

import Foundation
import UIKit

private let MB = 1024 * 1024

public class PCDownloader:ImageAccess,DataAccess {
    
    fileprivate let synchronizer: Sync
    
    fileprivate var memorySpace:Int
    
    fileprivate var diskSpace:Int
    
    public init(cacheTime: TimeInterval, memorySpace:Int = 100, diskSpace:Int = 0)
    {
        self.memorySpace = memorySpace
        self.diskSpace = diskSpace
        self.synchronizer = Sync(
            cacheTime: cacheTime,
            URLCache: URLCache(memoryCapacity: memorySpace * MB, diskCapacity: diskSpace * MB, diskPath: "diskload")
        )
    }
    
    public func imageWithURL(_ URL: Foundation.URL, completion: @escaping (UIImage?) -> Void) -> CancelImageLoading
    {
        return synchronizer.loadResource(ImageResource(URL: URL)) { (object) in
            switch object {
            case .error: completion(nil)
            case .noData: completion(nil)
            case .success(let image): completion(image)
            }
        }
    }
    
    public func dataWithURL(_ URL: Foundation.URL, completion: @escaping (Data?) -> Void) -> CancelImageLoading
    {
        return synchronizer.loadResource(DataResource(URL: URL)) { (object) in
            switch object {
            case .error: completion(nil)
            case .noData: completion(nil)
            case .success(let data): completion(data)
            }
        }
    }
    

}
