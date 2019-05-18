//
//  SessionDelegate.swift
//  ProjectC
//
//  Created by Prasad on 16/05/19.
//  Copyright © 2019 Prasad. All rights reserved.
//

import UIKit
import Foundation

class SessionDelegate: NSObject {
    
    typealias TaskCompletionHandler = (Data?, URLResponse?, NSError?) -> Void
    
    let cacheTime: TimeInterval
    
    private var completionHandlerForTask = [URLSessionTask: TaskCompletionHandler]()
    
    private var dataForTask = [URLSessionTask: NSMutableData?]()
    
    init(cacheTime: TimeInterval)
    {
        self.cacheTime = cacheTime
    }
    
    
    func setCompletionHandlerForTask(_ task: URLSessionDataTask, handler: @escaping TaskCompletionHandler)
    {
        completionHandlerForTask[task] = handler
    }
    
}

extension SessionDelegate: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
    {
        guard let mutableData = dataForTask[dataTask] else {
            
            dataForTask[dataTask] = NSMutableData(data: data)
            
            return
        }
        mutableData?.append(data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
            switch proposedResponse.response
            {
                case let response as HTTPURLResponse:
                    
                    var headers = response.allHeaderFields as! [String: String]
                    
                    headers["Cache-Control"] = "max-age=\(cacheTime)"
            
                    let modifiedResponse = HTTPURLResponse(url: response.url!,
                                                   statusCode: response.statusCode,
                                                   httpVersion: "HTTP/1.1",
                                                   headerFields: headers)
                    
                    let modifiedCachedResponse = CachedURLResponse(response: modifiedResponse!,
                                                           data: proposedResponse.data,
                                                           userInfo: proposedResponse.userInfo,
                                                           storagePolicy: proposedResponse.storagePolicy)
                    
                    completionHandler(modifiedCachedResponse)
                
                default:
                    
                    completionHandler(proposedResponse)
            }
    }
}

extension SessionDelegate: URLSessionTaskDelegate
{
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        let data = dataForTask[task] ?? nil
        
        completionHandlerForTask[task]?(data as Data?, task.response, error as NSError?)
        
        completionHandlerForTask[task] = nil
        
    }
}
