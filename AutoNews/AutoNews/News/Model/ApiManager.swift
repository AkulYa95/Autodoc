//
//  ApiManager.swift
//  AutoNews
//
//  Created by Ярослав Акулов on 24.07.2022.
//

import Foundation

class ApiManager {
    
    static let shared = ApiManager()
    private let mainURL = "https://webapi.autodoc.ru/api/news/"
    
    func fetchNews(fromPage page: Int) async throws -> Data? {
        guard let url = URL(string: mainURL.appending("\(page)/15")) else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    func fetchImage(withURL url: URL?) async throws -> Data? {
        guard let url = url else { return nil }
        do {
            if let cachedImageData = ImageStore.imageCache.object(forKey: NSString(string: url.path)) {
                return cachedImageData as Data
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            ImageStore.imageCache.setObject(data as NSData, forKey: NSString(string: url.path))
            return data
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
