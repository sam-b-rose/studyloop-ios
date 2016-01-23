//
//  ImageSizer.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/23/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import UIKit

class ImageSizer {
    static let imgs = ImageSizer()
    
    func resizeImageWithAspectFit(image:UIImage, size:CGSize) -> UIImage {
        let aspectFitSize = self.getAspectFitRect(origin: image.size, destination: size)
        let resizedImage = self.resizeImage(image, size: aspectFitSize)
        return resizedImage
    }
    
    func getAspectFitRect(origin src:CGSize, destination dst:CGSize) -> CGSize {
        var result = CGSizeZero
        var scaleRatio = CGPoint()
        
        if (dst.width != 0) {scaleRatio.x = src.width / dst.width}
        if (dst.height != 0) {scaleRatio.y = src.height / dst.height}
        let scaleFactor = max(scaleRatio.x, scaleRatio.y)
        
        result.width  = scaleRatio.x * dst.width / scaleFactor
        result.height = scaleRatio.y * dst.height / scaleFactor
        return result
    }
    
    func resizeImage(image:UIImage, size:CGSize) -> UIImage {
        let scale     = UIScreen.mainScreen().scale
        let size      = scale > 1 ? CGSizeMake(size.width/scale, size.height/scale) : size
        let imageRect = CGRectMake(0.0, 0.0, size.width, size.height);
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale);
        image.drawInRect(imageRect)
        let scaled = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return scaled;
    }
}