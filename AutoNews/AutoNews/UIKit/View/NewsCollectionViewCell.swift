//
//  NewsCollectionViewCell.swift
//  AutoNews
//
//  Created by Ярослав Акулов on 23.07.2022.
//

import UIKit
import Combine

class NewsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var newsImage: UIImageView!
    @IBOutlet private weak var loader: UIActivityIndicatorView!
    @IBOutlet private weak var newsTitle: UILabel!
    
    var viewModel: NewsCollectionViewCellViewModelProtocol? {
        didSet {
            binding()
        }
    }
    
    private var cancelable: Set<AnyCancellable> = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureContentView()
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func binding() {
        guard let viewModel = viewModel else { return }
        
        viewModel.newsItem
            .map { $0.title }
            .assign(to: \.text, on: newsTitle)
            .store(in: &cancelable)
        
         viewModel.imageData
            .sink(receiveValue: { data in
                guard let data = data as Data? else { return }
                self.newsImage.image = UIImage(data: data)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImage.image = nil
    }
    
    private func configureContentView() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        newsImage.layer.cornerRadius = 10
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
