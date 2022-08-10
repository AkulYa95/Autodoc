//
//  DetailViewControllerViewModel.swift
//  AutoNews
//
//  Created by Ярослав Акулов on 10.08.2022.
//

import Foundation
import Combine

protocol DetailViewControllerViewModelProtocol {
    var imageData: Published <Data?>.Publisher { get }
    var newsTypeString: String { get }
    var newsString: String { get }
    var newsTitle: String { get }
    var newsURL: URL? { get }
}

class DetailViewControllerViewModel {
    
    @Published private var newsImageData: Data? = nil
    private let newsItem: NewsItem
    
    private func getImageData() {
        guard let stringURL = newsItem.titleImageURl,
              let url = URL(string: stringURL) else {
                  return
              }
        Task {
            guard let data = try? await ApiManager.shared.fetchImage(withURL: url) else { return }
            DispatchQueue.main.async {
                self.newsImageData = data
            }
        }
    }
    
    private func convertStringFromDate(_ inputString: String?) -> String {
        guard let inputString = inputString else { return "" }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let outputFormater = DateFormatter()
        outputFormater.dateFormat = "dd.MM.yyyy"
        guard let inputDate = inputFormatter.date(from: inputString) else { return "" }
        let resultString = outputFormater.string(from: inputDate)
        return resultString
    }
    
    init(newsItem: NewsItem) {
        self.newsItem = newsItem
        getImageData()
    }
}

extension DetailViewControllerViewModel: DetailViewControllerViewModelProtocol {
    var newsURL: URL? {
        guard let stringURL = newsItem.fullURL else { return nil }
        return URL(string: stringURL)
    }
    
    var newsTitle: String {
        return newsItem.title  ?? ""
    }
    
    var newsString: String {
        let dateString = convertStringFromDate(newsItem.publishedDate)
        let description = newsItem.description ?? ""
        return "\(description) \n\n\(dateString)"
    }
    
    var newsTypeString: String {
        return newsItem.categoryType?.rawValue ?? ""
    }
    
    var imageData: Published<Data?>.Publisher {
        $newsImageData
    }
}
