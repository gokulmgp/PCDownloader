//
//  Accessors.swift
//  ProjectC
//
//  Created by Prasad on 16/05/19.
//  Copyright © 2019 Prasad. All rights reserved.
//

import Foundation
import UIKit

public typealias CancelImageLoading = () -> Void

protocol ImageAccess
{
    func imageWithURL(_ URL: URL, completion: @escaping (UIImage?) -> Void) -> CancelImageLoading
}

protocol DataAccess
{
    func dataWithURL(_ URL: URL, completion: @escaping (Data?) -> Void) -> CancelImageLoading
    
}


struct ImageResource {
    let URL: Foundation.URL
}

extension ImageResource: Resource {
    
    func request() -> URLRequest {
        return URLRequest(url: URL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
    }
    
    var parse: (Data) throws -> UIImage? {
        return { data in
            UIImage(data: data)
        }
    }
}


struct DataResource {
    let URL: Foundation.URL
}

extension DataResource: Resource {
    
    func request() -> URLRequest {
        return URLRequest(url: URL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
    }
    
    var parse: (Data) throws -> Data? {
        return { data in
            data
        }
    }
}
