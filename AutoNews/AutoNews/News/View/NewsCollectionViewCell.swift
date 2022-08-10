//
//  NewsCollectionViewCell.swift
//  AutoNews
//
//  Created by Ярослав Акулов on 23.07.2022.
//

import UIKit
import Combine

class NewsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var newsImageView: UIImageView!
    @IBOutlet private weak var loader: UIActivityIndicatorView!
    @IBOutlet private weak var newsTitle: UILabel!
    
    var viewModel: NewsCollectionViewCellViewModelProtocol? {
        didSet {
            binding()
        }
    }
    
    private var cancelable: Set<AnyCancellable> = []
    
    private func binding() {
        guard let viewModel = viewModel else { return }
        
        viewModel.newsItem
            .map { $0.title }
            .assign(to: \.text, on: newsTitle)
            .store(in: &cancelable)
        
        viewModel.imageData
            .sink(receiveValue: { data in
                guard let data = data as Data? else { return }
                
                self.newsImageView.image = UIImage(data: data)
                print("loaded image N\(viewModel.row)")
            })
            .store(in: &cancelable)
        
        viewModel.isLoading
            .sink(receiveValue: { isLoading in
                print("row №\(viewModel.row): \(isLoading)")
                if isLoading {
                    self.loader.startAnimating()
                } else {
                    self.loader.stopAnimating()
                }
            })
            .store(in: &cancelable)
    }
    
    private func resizeImageWithAspect(image: UIImage,
                                       scaledToMaxWidth width: CGFloat,
                                       maxHeight height: CGFloat) -> UIImage? {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
        
        let newHeight = oldHeight * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize,false,UIScreen.main.scale);
        
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImageView.image = nil
    }
}
