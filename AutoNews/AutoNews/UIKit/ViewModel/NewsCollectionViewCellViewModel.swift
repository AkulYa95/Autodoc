//
//  NewsCollectionViewCellViewModel.swift
//  AutoNews
//
//  Created by Ярослав Акулов on 24.07.2022.
//

import Combine
import Foundation

protocol NewsCollectionViewCellViewModelProtocol {
    var newsItem: Published <NewsItem>.Publisher { get }
    var imageData: Published <Data?>.Publisher { get }
    var isLoading: Published <Bool>.Publisher { get }
    var row: Int { get }

}

class NewsCollectionViewCellViewModel {
    
    @Published private var autoNewsItem: NewsItem
    @Published private var autoNewsImageData: Data? = nil {
        didSet {
            guard let _ = autoNewsImageData else { return }
            self.isLoadingImage = false
        }
    }
    @Published private var isLoadingImage: Bool = true

    
    private var cancelable: AnyCancellable?
    private var index: Int
    
    private func getImageData() {
         isLoadingImage = true
        guard let strinfgUrl = autoNewsItem.titleImageURl,
              let url = URL(string: strinfgUrl) else {
                  return
              }
            Task {
                guard let data = try? await ApiManager.shared.fetchImage(withURL: url) else { return }
                DispatchQueue.main.async {
                    self.autoNewsImageData = data
                    self.isLoadingImage = false
                }
            }
        
    }
    
    init(newsItem: NewsItem, indexPath: IndexPath) {
        self.autoNewsItem = newsItem
        index = indexPath.row
        getImageData()
    }
}

// MARK: - AutoNewsCollectionViewCellViewModelProtocol
extension NewsCollectionViewCellViewModel: NewsCollectionViewCellViewModelProtocol {
    var testString: String {
        autoNewsItem.titleImageURl ?? ""
    }
    
    var row: Int {
        index
    }
    
    
    var isLoading: Published<Bool>.Publisher {
        $isLoadingImage
    }
    
    var imageData: Published<Data?>.Publisher {
        $autoNewsImageData
    }
    
    
    var newsItem: Published<NewsItem>.Publisher {
        $autoNewsItem
    }
    
    
}
