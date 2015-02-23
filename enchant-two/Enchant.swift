//
//  Enchant.swift
//  Enchant
//
//  Created by Filip Hájek on 5.12.2014.
//  Copyright (c) 2014 Enchant. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import SwiftyJSON
import ImageLoader

class Enchant
{
    var url: String?
    var data: JSON!
    
    init(url: String)
    {
        self.url = url
    }
    
    func loadEnchant(completed: (enchant: Enchant?) -> Void) {
        Alamofire.request(.GET, "http://enchant-app.com/api/v1/enchant", parameters: ["url": self.url!])
            .validate()
            .responseJSON { (request, response, data, error) -> Void in
                if error == nil {
                    let json = JSON(data!)
                    
                    self.data = json
                     
                    println("Enchant loaded")
                    completed(enchant: self)
                }else{
                    println("Enchant not found")
                    completed(enchant: nil)
                }
        }
    }
    
    func uploadImage(image: UIImage, size: CGSize, completed: () -> Void) {
        Alamofire.request(.POST, "http://enchant-app.com/api/v1/enchant", parameters: ["url": self.url!])
            .response { (_, _, _, error) in
                if(error == nil) {
                    // Enchant created - attempt to upload photos
                    let imageToUpload = RBResizeImage(image, size)
                    
                    var parameters = [
                        "photo": NetData(jpegImage: imageToUpload, compressionQuality: 0.6, filename: "blabla.jpg"),
                        "url": self.url!
                    ]
                    
                    let urlRequest = urlRequestWithComponents("http://enchant-app.com/api/v1/enchant/photo", parameters)
                    
                    Alamofire.upload(urlRequest.0, urlRequest.1)
                        .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                            println("\(totalBytesWritten / 1024)kB / \(totalBytesExpectedToWrite / 1024)kB")
                        }
                        .response { (_, _, JSON, error) in
                            println("JSON \(JSON)")
                            println("ERROR \(error)")
                            
                            completed()
                    }
                }
        }
    }
    
    func loadPhotos() -> Void {
        for var i = 0; i < self.data["photos"].count; ++i {
            //self.photos

        }
    }
}

class EnchantPhoto
{
    var photoID: String?
    var url: String?
    
    init(photoID: String, url: String)
    {
        self.photoID = photoID
        self.url = url
        
        
    }
}