//
//  Sync.swift
//  ProjectC
//
//  Created by Prasad on 16/05/19.
//  Copyright © 2019 Prasad. All rights reserved.
//

import UIKit
import Foundation

protocol Resource
{
    
    func request() -> URLRequest
    
    associatedtype ParsedObject
    
    var parse: (Data) throws -> ParsedObject { get }
    
}

enum SyncResult<Result>
{
    case success(Result)
    case noData
    case error(Error)
    
}

enum SyncError: Error
{
    case statusError(status: Int)
    case urlSessionError(NSError)
}

private extension SyncResult {
    
    static func resultWithResponse(_ response: URLResponse?, error: NSError?) -> SyncResult?
    {
        guard error == nil else
        {
            return self.error(SyncError.urlSessionError(error!))
        }
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        
        guard 200..<300 ~= statusCode else
        {
            return self.error(SyncError.statusError(status: statusCode))
        }
        return nil
    }
}

class Sync
{
    typealias CancelLoading = () -> Void
    
    private lazy var session = self.createSession()
    
    private var sessionDelegate: SessionDelegate { return session.delegate as! SessionDelegate }
    
    private let sessionConfiguration: URLSessionConfiguration
    
    private let cacheTime: TimeInterval
    
    
    
    init(cacheTime: TimeInterval, URLCache: Foundation.URLCache? = URLSessionConfiguration.default.urlCache)
    {
        self.cacheTime = cacheTime
        
        self.sessionConfiguration = URLSessionConfiguration.default
        
        self.sessionConfiguration.urlCache = URLCache
    }
    
    private func createSession() -> URLSession {
        
        return URLSession(
            configuration: self.sessionConfiguration,
            delegate: SessionDelegate(cacheTime: self.cacheTime),
            delegateQueue: OperationQueue.main
        )
        
    }
    
    func cancelSession()
    {
        session.invalidateAndCancel()
        
        session = createSession()
    }
    
    
    
    func loadResource<R: Resource, Object>
        (_ resource: R, completion: @escaping (SyncResult<Object>) -> ()) -> CancelLoading where R.ParsedObject == Object {
        
        func completeOnMainThread(_ result: SyncResult<Object>)
        {
            if case .error = result { print(result) }
            OperationQueue.main.addOperation{ completion(result) }
        }
        
        let request = resource.request()
        
        let task = session.dataTask(with: request)
        
//        print("Request: \(request)")
        
        sessionDelegate.setCompletionHandlerForTask(task) { (data, response, error) in
            
            guard error?.code != NSURLErrorCancelled else {
                
                print("Request with URL: \(String(describing: request.url)) got cancelled")
                
                return // cancel quitely
            }
            
//            print("Response: \(String(describing: response))")
            
            if let result = SyncResult<Object>.resultWithResponse(response, error: error)
            {
                completeOnMainThread(result)
                
                return
            }
            
            guard let data = data, data.count > 0 else {
                
                completeOnMainThread(.noData)
                
                return
            }
            
            do
            {
                let object = try resource.parse(data)
                
                completeOnMainThread(.success(object))
                
            } catch
            {
                completeOnMainThread(.error(error))
            }
        }
        task.resume()
        
        return { [weak task] in
            task?.cancel()
        }
    }
    
}
