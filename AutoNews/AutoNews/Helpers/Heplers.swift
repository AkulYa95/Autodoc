//
//  Extension + UIImageView.swift
//  AutoNews
//
//  Created by Ярослав Акулов on 07.08.2022.
//

import UIKit

class ImageStore {
    static let imageCache = NSCache < NSString, NSData>()
}

struct SegueIdentifier {
    static let detail = "Detail"
    static let collection = "Collection"
}

