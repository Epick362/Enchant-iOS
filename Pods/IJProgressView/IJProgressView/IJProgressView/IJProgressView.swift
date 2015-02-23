//
//  IJProgressView.swift
//  IJProgressView
//
//  Created by Isuru Nanayakkara on 1/14/15.
//  Copyright (c) 2015 Appex. All rights reserved.
//

import UIKit

public class IJProgressView {
    
    var progressView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    
    public class var shared: IJProgressView {
        struct Static {
            static let instance: IJProgressView = IJProgressView()
        }
        return Static.instance
    }
    
    public func showProgressView(view: UIView) {
        // Blur Effect
        blurEffectView.frame = view.frame
        blurEffectView.center = view.center
        blurEffectView.alpha = 0.0
        
        // Vibrancy Effect
        var vibrancyEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        var vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = view.bounds
        
        // Label for vibrant text
        var vibrantLabel = UILabel()
        vibrantLabel.text = "Please wait"
        vibrantLabel.font = UIFont.systemFontOfSize(24.0)
        vibrantLabel.sizeToFit()
        vibrantLabel.center = CGPoint(x: view.center.x, y: (view.center.y + 50))
        // Add label to the vibrancy view
        vibrancyEffectView.contentView.addSubview(vibrantLabel)
        
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = blurEffectView.center
        
        blurEffectView.contentView.addSubview(activityIndicator)
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        
        view.addSubview(blurEffectView)
        activityIndicator.startAnimating()
        
        UIView.animateWithDuration(0.5, animations: {
            self.blurEffectView.alpha = 1.0;
        })
    }
    
    public func hideProgressView() {
        UIView.animateWithDuration(0.5, animations: {
            self.blurEffectView.alpha = 0.0;
        }, completion: { (done) -> Void in
            self.activityIndicator.stopAnimating()
            self.blurEffectView.removeFromSuperview()
        })
    }
}