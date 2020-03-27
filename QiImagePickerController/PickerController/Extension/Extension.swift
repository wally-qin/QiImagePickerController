//
//  UIView+Extension.swift
//  QiImagePickerController
//
//  Created by QLY on 2020/3/18.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit

var iPhoneXSeriesBottomInset : CGFloat {
    //directionalLayoutMargins
    if #available (iOS 13,*) {
        if let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) {
            return window.rootViewController?.view.layoutMargins.bottom ?? 0.0
        } else {
            return 0.0
        }
    } else {
         return UIApplication.shared.keyWindow?.rootViewController?.view.layoutMargins.bottom ?? 0.0
    }
   
}
var KStatusBarHeight : CGFloat {
    var statusBarHeight : CGFloat
    
    if #available (iOS 13,*) {
        if let statusBarManager = UIApplication.shared.windows.first?.windowScene?.statusBarManager {
            statusBarHeight = statusBarManager.statusBarFrame.height
        } else {
            statusBarHeight = 20
        }
    } else {
        statusBarHeight = UIApplication.shared.statusBarFrame.height
    }
    return statusBarHeight
}

extension UIImage {
    static func qi_colorImage(_ color : UIColor)->UIImage {
        let rect = CGRect.init(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

extension UIView {

    var qi_centerX : CGFloat {
        get {
            self.center.x
        }
        set {
            var center = self.center
            center.x = newValue
            self.center = center
        }
    }
    var qi_centerY : CGFloat {
        get {
            self.center.y
        }
        set {
           var center = self.center
            center.y = newValue
            self.center = center
        }
    }
    
    var qi_top : CGFloat {
        get {
            self.frame.origin.y
        }
        set {
            self.frame = CGRect.init(x: self.qi_left, y: newValue, width: self.qi_width, height: self.qi_height)
        }
    }
    var qi_bottom : CGFloat {
        get {
            self.frame.origin.y + self.frame.size.height
        }
        set {
            self.frame = CGRect.init(x: self.qi_left, y: newValue - self.qi_height, width: self.qi_width, height: self.qi_height)
        }
    }
    var qi_left : CGFloat {
        get {
            self.frame.origin.x
        }
        set {
            self.frame = CGRect.init(x: newValue, y: self.qi_top, width: self.qi_width, height: self.qi_height)
        }
    }
    var qi_right : CGFloat {
        get {
            self.frame.origin.x + self.frame.size.width
        }
        set {
            self.frame = CGRect.init(x: newValue - self.qi_width, y: self.qi_top, width: self.qi_width, height: self.qi_height)
        }
    }
    
    var qi_x: CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.x
        }
    }
    var qi_y: CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.y
        }
    }
    var qi_width: CGFloat {
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.width
        }
    }
    var qi_height: CGFloat {
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.height
        }
    }
    var qi_side: CGFloat {
        set {
            var frame = self.frame
            frame.size.height = newValue
            frame.size.width = newValue
            self.frame = frame
        }
        get {
            return min(self.frame.size.width, self.frame.size.height)
        }
    }
    var qi_size: CGSize {
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
        get {
            return self.frame.size
        }
    }
    var qi_origin: CGPoint {
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin
        }
    }
    
}

extension UIColor {
    
    class func qi_colorWithHexString(_ hex : String) -> UIColor {
        var colorString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if colorString.count >= 6 && colorString.count <= 10 {
            if colorString.hasPrefix("#") {
                colorString = colorString.replacingOccurrences(of: "#", with: "")
            }
            if colorString.hasPrefix("0x") {
                colorString = colorString.replacingOccurrences(of: "0x", with: "")
            }
            if colorString.hasPrefix("0X") {
                colorString = colorString.replacingOccurrences(of: "0X", with: "")
            }
            if colorString.count == 6 {
                colorString = colorString.appending("FF")
            }
            if colorString.count != 8 {
                return .clear
            }
        } else {
            return .clear
        }
        
        let redRange = ..<colorString.index(colorString.startIndex, offsetBy: 2)
        let greenRange = colorString.index(colorString.startIndex, offsetBy: 2) ..< colorString.index(colorString.startIndex, offsetBy: 4)
        let blueRange = colorString.index(colorString.startIndex, offsetBy: 4) ..< colorString.index(colorString.startIndex, offsetBy: 6)
        let alphaRange = colorString.index(colorString.endIndex, offsetBy: -2)...
        
        let redString = colorString[redRange]
        let greenString = colorString[greenRange]
        let blueString = colorString[blueRange]
        let alphaString = colorString[alphaRange]
        
        var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0, a: UInt64 = 0
        Scanner(string: String(redString)).scanHexInt64(&r)
        Scanner(string: String(greenString)).scanHexInt64(&g)
        Scanner(string: String(blueString)).scanHexInt64(&b)
        Scanner(string: String(alphaString)).scanHexInt64(&a)
        
        return .init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }
    static func dynamicColor(lightModeColor:UIColor,darkModeColor:UIColor)->UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ? darkModeColor: lightModeColor
            }
        } else {
            return lightModeColor
        }
    }
}
