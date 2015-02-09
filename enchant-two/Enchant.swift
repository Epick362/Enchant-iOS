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
    
    func loadEnchant(completed: (enchant: JSON?) -> Void) {
        Alamofire.request(.GET, "http://enchant-app.com/api/v1/enchant", parameters: ["url": self.url!])
            .validate()
            .responseJSON { (request, response, data, error) -> Void in
                if error == nil {
                    let json = JSON(data!)
                    
                    self.data = json
                    
                    println("Enchant loaded")
                    completed(enchant: json)
                }else{
                    println("Enchant not found")
                    completed(enchant: nil)
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