//
//  Utilities.swift
//  SampleFeed
//
//  Created by Prasad on 17/05/19.
//  Copyright © 2019 Prasad. All rights reserved.
//

import Foundation
import UIKit

struct Device {
    // iDevice detection code
    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_RETINA = UIScreen.main.scale >= 2.0
    
    static let SCREEN_WIDTH = Int(UIScreen.main.bounds.size.width)
    static let SCREEN_HEIGHT = Int(UIScreen.main.bounds.size.height)
    static let SCREEN_MAX_LENGTH = Int( max(SCREEN_WIDTH, SCREEN_HEIGHT) )
    static let SCREEN_MIN_LENGTH = Int( min(SCREEN_WIDTH, SCREEN_HEIGHT) )
    
    static let IS_IPHONE_4_OR_LESS = IS_IPHONE && SCREEN_MAX_LENGTH < 568
    static let IS_IPHONE_5 = IS_IPHONE && SCREEN_MAX_LENGTH == 568
    static let IS_IPHONE_6 = IS_IPHONE && SCREEN_MAX_LENGTH == 667
    static let IS_IPHONE_6P = IS_IPHONE && SCREEN_MAX_LENGTH == 736
    static let IS_IPHONE_X = IS_IPHONE && SCREEN_MAX_LENGTH == 812
}


extension UIColor {
    public convenience init?(hex: String) {
            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
            
            var rgb: UInt32 = 0
            
            var r: CGFloat = 0.0
            var g: CGFloat = 0.0
            var b: CGFloat = 0.0
            var a: CGFloat = 1.0
            
            let length = hexSanitized.count
            
            guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
            
            if length == 6 {
                r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
                g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
                b = CGFloat(rgb & 0x0000FF) / 255.0
                
            } else if length == 8 {
                r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
                g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
                b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
                a = CGFloat(rgb & 0x000000FF) / 255.0
                
            } else {
                return nil
            }
            
            self.init(red: r, green: g, blue: b, alpha: a)
        }
        
        // MARK: - Computed Properties
        
        var toHex: String? {
            return toHex()
        }
        
        // MARK: - From UIColor to String
        
        func toHex(alpha: Bool = false) -> String? {
            guard let components = cgColor.components, components.count >= 3 else {
                return nil
            }
            
            let r = Float(components[0])
            let g = Float(components[1])
            let b = Float(components[2])
            var a = Float(1.0)
            
            if components.count >= 4 {
                a = Float(components[3])
            }
            
            if alpha {
                return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
            } else {
                return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
            }
        }
}

extension Bundle {
    
    func apiBaseUrl() -> String {
        return infoValueForKey("API_BASE_URL")!
    }
    
    func infoValueForKey<Value>(_ key: String) -> Value? {
        return infoDictionary![key] as? Value
    }
}


extension Array {
    
    func chunked(into size: Int) -> [[Element]]
    {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
