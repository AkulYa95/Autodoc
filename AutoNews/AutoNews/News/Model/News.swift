//
//  News.swift
//  AutoNews
//
//  Created by Ярослав Акулов on 23.07.2022.
//

import Foundation



// MARK: - News
struct News: Codable {
    let news: [NewsItem]?
    let totalCount: Int?
}

// MARK: - NewsElement
struct NewsItem: Identifiable, Codable {
    let id: Int?
    let title: String?
    let description: String?
    let publishedDate: String?
    let url: String?
    let fullURL: String?
    let titleImageURl: String?
    let categoryType: CategoryType?
    var imageData: Data?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case publishedDate
        case url
        case fullURL = "fullUrl"
        case titleImageURl = "titleImageUrl"
        case categoryType
        case imageData
    }
    
    enum CategoryType: String, Codable {
        case autoNews = "Автомобильные новости"
        case companyNews = "Новости компании"
    }
}
