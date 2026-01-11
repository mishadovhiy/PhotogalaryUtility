//
//  UIImage.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit

extension UIImage {
    func changeSize(newWidth:CGFloat, from:CGSize? = nil, origin:CGPoint = .zero) -> UIImage {
        let widthPercent = newWidth / (from?.width ?? self.size.width)
        let proportionalSize: CGSize = .init(width: newWidth, height: widthPercent * (from?.height ?? self.size.height))
        let renderer = UIGraphicsImageRenderer(size: proportionalSize)
        let newImage = renderer.image { _ in
            self.draw(in: CGRect(origin: origin, size: proportionalSize))
        }
        return newImage
    }
}

extension Data {
    var imageDate: String? {
        if let source = CGImageSourceCreateWithData(self as CFData, nil),
           let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
           let exif = metadata[kCGImagePropertyExifDictionary] as? [CFString: Any],
           let dateString = exif[kCGImagePropertyExifDateTimeOriginal] as? String
        {
            return dateString
        } else {
            return nil
        }
    }
}
