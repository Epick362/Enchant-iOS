//
//  NetData.swift
//  Net
//
//  Created by Le Van Nghia on 8/3/14.
//  Copyright (c) 2014 Le Van Nghia. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

enum MimeType: String {
    case ImageJpeg = "image/jpeg"
    case ImagePng = "image/png"
    case ImageGif = "image/gif"
    case Json = "application/json"
    case Unknown = ""
    
    func getString() -> String? {
        switch self {
        case .ImagePng:
            fallthrough
        case .ImageJpeg:
            fallthrough
        case .ImageGif:
            fallthrough
        case .Json:
            return self.rawValue
        case .Unknown:
            fallthrough
        default:
            return nil
        }
    }
}

class NetData
{
    let data: NSData
    let mimeType: MimeType
    let filename: String
    
    init(data: NSData, mimeType: MimeType, filename: String) {
        self.data = data
        self.mimeType = mimeType
        self.filename = filename
    }
    
    init(pngImage: UIImage, filename: String) {
        data = UIImagePNGRepresentation(pngImage)
        self.mimeType = MimeType.ImagePng
        self.filename = filename
    }
    
    init(jpegImage: UIImage, compressionQuality: CGFloat, filename: String) {
        data = UIImageJPEGRepresentation(jpegImage, compressionQuality)
        self.mimeType = MimeType.ImageJpeg
        self.filename = filename
    }
}


func RBSquareImageTo(image: UIImage, size: CGSize) -> UIImage {
    return RBResizeImage(RBSquareImage(image), size)
}

func RBSquareImage(image: UIImage) -> UIImage {
    var originalWidth  = image.size.width
    var originalHeight = image.size.height
    
    var edge: CGFloat
    if originalWidth > originalHeight {
        edge = originalHeight
    } else {
        edge = originalWidth
    }
    
    var posX = (originalWidth  - edge) / 2.0
    var posY = (originalHeight - edge) / 2.0
    
    var cropSquare = CGRectMake(posX, posY, edge, edge)
    
    var imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
    return UIImage(CGImage: imageRef, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)!
}

func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
    } else {
        newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRectMake(0, 0, newSize.width, newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.drawInRect(rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}

func urlRequestWithComponents(urlString: String, parameters: NSDictionary) -> (URLRequestConvertible, NSData) {
    
    // create url request to send
    var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
    //let boundaryConstant = "myRandomBoundary12345"
    let boundaryConstant = "NET-POST-boundary-\(arc4random())-\(arc4random())"
    let contentType = "multipart/form-data;boundary="+boundaryConstant
    mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
    
    
    // create upload data to send
    let uploadData = NSMutableData()
    
    // add parameters
    for (key, value) in parameters {
        
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        if value is NetData {
            // add image
            var postData = value as NetData
            
            
            //uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(postData.filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            
            // append content disposition
            var filenameClause = " filename=\"\(postData.filename)\""
            let contentDispositionString = "Content-Disposition: form-data; name=\"\(key)\";\(filenameClause)\r\n"
            let contentDispositionData = contentDispositionString.dataUsingEncoding(NSUTF8StringEncoding)
            uploadData.appendData(contentDispositionData!)
            
            
            // append content type
            //uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!) // mark this.
            let contentTypeString = "Content-Type: \(postData.mimeType.getString())\r\n\r\n"
            let contentTypeData = contentTypeString.dataUsingEncoding(NSUTF8StringEncoding)
            uploadData.appendData(contentTypeData!)
            uploadData.appendData(postData.data)
            
        }else{
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
    }
    uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    
    
    
    // return URLRequestConvertible and NSData
    return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
}
