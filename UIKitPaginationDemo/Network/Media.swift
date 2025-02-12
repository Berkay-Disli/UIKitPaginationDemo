//
//  Media.swift
//  SnapReel
//
//

import UIKit

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        mimeType = "image/jpeg"
        filename = "imagefile.jpg"
        guard let data = image.jpegData(compressionQuality: 0.2) else { return nil }
        self.data = data
    }
}
