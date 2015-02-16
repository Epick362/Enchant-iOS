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
    var photos: [EnchantPhoto]?
    
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
    
    func uploadImage(image: UIImage, completed: () -> Void) {
        Alamofire.request(.POST, "http://enchant-app.com/api/v1/enchant", parameters: ["url": self.url!])
            .response { (_, _, _, error) in
                if(error == nil) {
                    // Enchant created - attempt to upload photos
                    let imageToUpload = RBResizeImage(image, CGSize(width: 816, height: 1088))
                    
                    var parameters = [
                        "photo": NetData(jpegImage: imageToUpload, compressionQuality: 30, filename: "blabla.jpg"),
                        "url": self.url!
                    ]
                    
                    let urlRequest = urlRequestWithComponents("http://enchant-app.com/api/v1/enchant/photo", parameters)
                    
                    Alamofire.upload(urlRequest.0, urlRequest.1)
                        .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                            println("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
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
            //self.photos = EnchantPhoto(photoID: self.data["photos"][i]["name"].string!, url: self.data["photos"][i]["url"].string!)
            let url = self.data["photos"][i]["url"].string
            println("photo n. \(i) url: \(url)")
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