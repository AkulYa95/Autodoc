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
    var isErrorOccurs: Published <Bool>.Publisher { get }
    var newsCount: Int { get }
    var navigationTitle: String { get }
    var isLoadingData: Published <Bool>.Publisher { get }
    var collectionViewCellId: String { get }
    func fetchNextPage()
    func viewModelForCell(atIndexPath indexPath: IndexPath) -> NewsCollectionViewCellViewModelProtocol?
    func selectItemAt(indexPath: IndexPath)
    func viewModelForDetailViewController() -> DetailViewControllerViewModelProtocol?
    func refreshNews()
}

class NewsViewControllerViewModel {
    
    @Published private var autoNews: [NewsItem] = []
    @Published private var isLoading: Bool = true
    @Published private var jsonError: Bool = false
    private var fetchingPage = 1
    private var cancelable: AnyCancellable?
    private var shouldFetch = true
    private var selectedIndexPath: IndexPath?
    
}

// MARK: - AutoNewsViewControllerViewModelProtocol
extension NewsViewControllerViewModel: NewsViewControllerViewModelProtocol {
    func refreshNews() {
        Task {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            do {
                let data = try await ApiManager.shared.fetchNews(fromPage: 1)
                let decodeData = try? JSONDecoder().decode(News.self, from: data ?? Data())
                DispatchQueue.main.async {
                    self.autoNews = decodeData?.news ?? []
                    self.jsonError = false
                    self.shouldFetch = true
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.jsonError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    
    func viewModelForDetailViewController() -> DetailViewControllerViewModelProtocol? {
        guard let row = selectedIndexPath?.row else { return nil }
        return DetailViewControllerViewModel(newsItem: autoNews[row])
    }
    
    func selectItemAt(indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
    }
    
    var isErrorOccurs: Published<Bool>.Publisher {
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
    
    func fetchNextPage() {
        guard shouldFetch else { return }
        shouldFetch = false
        Task {
            do {
                let data = try await ApiManager.shared.fetchNews(fromPage: fetchingPage)
                let decodeData = try? JSONDecoder().decode(News.self, from: data ?? Data())
                DispatchQueue.main.async {
                    self.autoNews.append(contentsOf: decodeData?.news ?? [])
                    self.jsonError = false
                    self.shouldFetch = true
                    self.fetchingPage += 1
                    self.isLoading = false
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

