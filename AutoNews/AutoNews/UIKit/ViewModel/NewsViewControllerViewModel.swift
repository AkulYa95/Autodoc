//
//  AutoNewsViewControllerViewModel.swift
//  AutoNews
//
//  Created by Ярослав Акулов on 24.07.2022.
//

import Combine
import Foundation

protocol NewsViewControllerViewModelProtocol {
    var newsPublisher: Published <[NewsItem]>.Publisher { get }
    var isErrorOcures: Published <Bool>.Publisher { get }
    var newsCount: Int { get }
    var navigationTitle: String { get }
    var isLoadingData: Published <Bool>.Publisher { get }
    var collectionViewCellId: String { get }
    func fetchNews()
    func viewModelForCell(atIndexPath indexPath: IndexPath) -> NewsCollectionViewCellViewModelProtocol?
    
}

class NewsViewControllerViewModel {
    
    @Published private var autoNews: [NewsItem] = []
    @Published private var isLoading: Bool = true
    @Published private var jsonError: Bool = false
    private var cancelable: AnyCancellable?
    
}

// MARK: - AutoNewsViewControllerViewModelProtocol
extension NewsViewControllerViewModel: NewsViewControllerViewModelProtocol {
    var isErrorOcures: Published<Bool>.Publisher {
        $jsonError
    }
    
    var isLoadingData: Published<Bool>.Publisher {
        $isLoading
    }
    
    
    var collectionViewCellId: String {
        return "NewsCollectionViewCell"
    }
    
    
    var navigationTitle: String {
        return "Auto news"
    }
    
    var newsCount: Int {
        return autoNews.count
    }
    var newsPublisher: Published <[NewsItem]>.Publisher {
        return $autoNews
    }

    func viewModelForCell(atIndexPath indexPath: IndexPath) -> NewsCollectionViewCellViewModelProtocol? {
        let newsItem = autoNews[indexPath.row]
        return NewsCollectionViewCellViewModel(newsItem: newsItem, indexPath: indexPath)
    }
    
    func fetchNews() {
        Task {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            do {
            let data = try await ApiManager.shared.fetchNews()
            let decodeData = try? JSONDecoder().decode(News.self, from: data ?? Data())
                DispatchQueue.main.async {
                    self.autoNews = decodeData?.news ?? []
                    self.isLoading = false
                    self.jsonError = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.jsonError = true
                    self.isLoading = false
                }
            }
        }
    }
}

