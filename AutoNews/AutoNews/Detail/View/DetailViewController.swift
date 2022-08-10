//
//  DetailViewController.swift
//  AutoNews
//
//  Created by Ярослав Акулов on 10.08.2022.
//

import UIKit
import Combine

class DetailViewController: UIViewController {
    
    @IBOutlet private weak var newsImageView: UIImageView!
    @IBOutlet private weak var newsLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var linkButton: UIButton!
    @IBOutlet private weak var loader: UIActivityIndicatorView!
    
    private var cancelable: Set<AnyCancellable> = []
    
    var viewModel: DetailViewControllerViewModelProtocol? {
        didSet {
            bind()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.startAnimating()
        configureView()
        guard let viewModel = viewModel else { return }
        configure(withViewModel: viewModel)
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        viewModel.imageData
            .sink { data in
                guard let data = data else { return }
                self.newsImageView.image = UIImage(data: data)
                if self.loader.isAnimating {
                    self.loader.stopAnimating()
                }
            }
            .store(in: &cancelable)
    }
    
    private func configureView() {
        newsImageView.layer.cornerRadius = 10
        newsImageView.contentMode = .scaleToFill
    }
    private func configure(withViewModel viewModel:DetailViewControllerViewModelProtocol) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.configure(withViewModel: viewModel)
            }
            return
        }
        typeLabel.text = viewModel.newsTypeString
        titleLabel.text = viewModel.newsTitle
        newsLabel.text = viewModel.newsString
        linkButton.backgroundColor = #colorLiteral(red: 0.8022577167, green: 0.1396244764, blue: 0.1869231164, alpha: 1)
        linkButton.layer.shadowColor = UIColor.black.cgColor
        linkButton.layer.shadowOpacity = 1
        linkButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        linkButton.layer.shadowRadius = 5
        linkButton.layer.cornerRadius = 10
        linkButton.tintColor = .white
        
    }
    
    @IBAction func linkButtonAction(_ sender: UIButton) {
        guard let viewModel = viewModel,
              let url = viewModel.newsURL else {
                  return
              }
        UIApplication.shared.openURL(url)
    }
}
