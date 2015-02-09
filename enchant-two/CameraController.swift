//
//  CameraViewController.swift
//  Enchant
//
//  Created by Filip Hájek on 8.12.2014.
//  Copyright (c) 2014 Enchant. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

enum Status: Int {
    case Preview, Still, Error
}

class CameraController: UIViewController, EnchantCameraDelegate {
    
    @IBOutlet weak var cameraStill: UIImageView!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var cameraCapture: UIButton!
    
    var preview: AVCaptureVideoPreviewLayer?
    
    var enchantUrl: String?
    
    var camera: EnchantCamera?
    var status: Status = .Preview
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.initializeCamera()

        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.establishVideoPreviewArea()
    }
    
    func initializeCamera() {
        self.camera = EnchantCamera(sender: self)
    }
    
    func establishVideoPreviewArea() {
        self.preview = AVCaptureVideoPreviewLayer(session: self.camera?.session)
        self.preview?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.preview?.frame = self.cameraPreview.frame
        self.cameraPreview.layer.addSublayer(self.preview)
    }
    
    // MARK: Button Actions
    
    @IBAction func captureFrame(sender: AnyObject) {
        if self.status == .Preview {
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.cameraPreview.alpha = 0.0;
            })
            
            self.camera?.captureStillImage({ (image) -> Void in
                if image != nil {
                    // Attempt to create a new enchant
                    Alamofire.request(.POST, "http://enchant-app.com/api/v1/enchant", parameters: ["url": self.enchantUrl!])
                        .response { (_, _, _, error) in
                            if(error == nil) {
                                // Enchant created - attempt to upload photos
                                let imageToUpload = RBResizeImage(image!, CGSize(width: 816, height: 1088))
                                
                                var parameters = [
                                    "photo": NetData(jpegImage: imageToUpload, compressionQuality: 30, filename: "blabla.jpg"),
                                    "url": self.enchantUrl!
                                ]
                                
                                let urlRequest = self.urlRequestWithComponents("http://enchant-app.com/api/v1/enchant/photo", parameters: parameters)
                                
                                Alamofire.upload(urlRequest.0, urlRequest.1)
                                    .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                                        println("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                                    }
                                    .response { (_, _, JSON, error) in
                                        println("JSON \(JSON)")
                                        println("ERROR \(error)")
                                        
                                        self.navigationController?.popViewControllerAnimated(true)
                                }
                            }
                    }
                    
                    self.cameraStill.image = image;
                    
                    UIView.animateWithDuration(0.225, animations: { () -> Void in
                        self.cameraStill.alpha = 1.0;
                    })
                    self.status = .Still
                } else {
                    self.status = .Error
                }
                
                self.cameraCapture.setTitle("Reset", forState: UIControlState.Normal)
            })
        } else if self.status == .Still || self.status == .Error {
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.cameraStill.alpha = 0.0;
                self.cameraPreview.alpha = 1.0;
                self.cameraCapture.setTitle("Capture", forState: UIControlState.Normal)
                }, completion: { (done) -> Void in
                    self.cameraStill.image = nil;
                    self.status = .Preview
            })
        }
    }
    
    // MARK: Camera Delegate
    
    func cameraSessionConfigurationDidComplete() {
        self.camera?.startCamera()
    }
    
    func cameraSessionDidBegin() {
        UIView.animateWithDuration(0.225, animations: { () -> Void in
            self.cameraPreview.alpha = 1.0
            self.cameraCapture.alpha = 1.0
        })
    }
    
    func cameraSessionDidStop() {
        UIView.animateWithDuration(0.225, animations: { () -> Void in
            self.cameraPreview.alpha = 0.0
        })
    }
    
    func urlRequestWithComponents(urlString:String, parameters:NSDictionary) -> (URLRequestConvertible, NSData) {
        
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
}


