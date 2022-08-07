//
//  UIKitNewsViewController.swift
//  AutoNews
//
//  Created by Ярослав Акулов on 23.07.2022.
//

import UIKit
import Combine

class NewsViewController: UIViewController {

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var cancelable: Set<AnyCancellable> = []
    var viewModel: NewsViewControllerViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        title = viewModel?.navigationTitle
        collectionView.dataSource = self
        collectionView.delegate = self
        viewModel?.fetchNews()
        binding()
    }
        
    private func binding() {
        viewModel?.isLoadingData
            .sink(receiveValue: { isLoading in
                if isLoading {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                    self.collectionView.reloadData()
                }
            })
            .store(in: &cancelable)
        
        viewModel?.isErrorOcures
            .sink(receiveValue: { isError in
                guard isError else { return }
                self.showErrorAlert()
            })
            .store(in: &cancelable)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error with connection",
                                      message: "Trouble with internet",
                                      preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: "Try again", style: .default) {_ in
            self.viewModel?.fetchNews()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(tryAgainAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension NewsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel?.newsCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.collectionViewCellId,
                                                            for: indexPath) as? NewsCollectionViewCell else {
                  return UICollectionViewCell()
              }
        cell.viewModel = viewModel.viewModelForCell(atIndexPath: indexPath)
        return cell
    }
    
    
}

extension NewsViewController: UICollectionViewDelegate {

}

//extension NewsViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        let inset: CGFloat = 10
//        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        return CGSize(width: UIScreen.main.bounds.width, height: 400)
//    }
//}
