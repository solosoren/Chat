//
//  CloudkitCKAsset.swift
//  Chat
//
//  Created by Soren Nelson on 5/22/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit

enum ImageFileType {
    case jpg(compressionQuality: CGFloat)
    case png
    
    var fileExtension: String {
        switch self {
        case .jpg(_):
            return ".jpg"
        case .png:
            return ".png"
        }
    }
}

enum ImageError: Error {
    case unableToConvertImageToData
}

extension CKAsset {
    convenience init(image: UIImage, fileType: ImageFileType = .jpg(compressionQuality: 70)) throws {
        let url = try image.saveToTempLocationWithFileType(fileType)
        self.init(fileURL: url)
    }
    
    var image: UIImage? {
        guard let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) else { return nil }
        return image
    }
}

extension UIImage {
    
    func saveToTempLocationWithFileType(_ fileType: ImageFileType) throws -> URL {
        let imageData: Data?
        
        switch fileType {
        case .jpg(let quality):
            imageData = UIImageJPEGRepresentation(self, quality)
        case .png:
            imageData = UIImagePNGRepresentation(self)
        }
        guard let data = imageData else {
            throw ImageError.unableToConvertImageToData
        }
        
        let filename = ProcessInfo.processInfo.globallyUniqueString + fileType.fileExtension
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        try data.write(to: url, options: .atomicWrite)
        
        return url
    }
    
    
    
    
}
