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
    private var refreshControl: UIRefreshControl?
    var viewModel: NewsViewControllerViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel?.navigationTitle
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.collectionViewLayout = getCompositionalLayout()
        viewModel?.refreshNews()
        binding()
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Минуточку....")
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        guard let refreshControl = refreshControl else { return }
        collectionView.addSubview(refreshControl)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewModel = viewModel,
              let destinationViewController = segue.destination as? DetailViewController else {
                  return
              }
        destinationViewController.viewModel = viewModel.viewModelForDetailViewController()
    }
    
    @objc
    private func refresh() {
        guard let viewModel = viewModel else { return }
        viewModel.refreshNews()
    }
    
    private func binding() {
        viewModel?.isLoadingData
            .sink(receiveValue: { isLoading in
                DispatchQueue.main.async {
                    if isLoading {
                        self.activityIndicator.startAnimating()
                    } else {
                        self.activityIndicator.stopAnimating()
                        self.refreshControl?.endRefreshing()
                        self.collectionView.reloadData()
                    }
                }
            })
            .store(in: &cancelable)
        
        viewModel?.isErrorOccurs
            .sink(receiveValue: { isError in
                guard isError else { return }
                self.showErrorAlert()
            })
            .store(in: &cancelable)
    }
    
    
    private func getCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                             heightDimension: .fractionalHeight(1/3)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        // MARK: Group 1
        let group1Item1 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2),
                                                                                    heightDimension: .fractionalHeight(1)))
        group1Item1.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let nestedGroup1Item1 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                          heightDimension: .fractionalHeight(1/2)))
        nestedGroup1Item1.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let nestedGroup1 = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2),
                                                                                               heightDimension: .fractionalHeight(1)),
                                                            subitems: [nestedGroup1Item1])
        let group1 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                           heightDimension: .fractionalHeight(1/3)),
                                                        subitems: [group1Item1, nestedGroup1])
        
        
        // MARK: Group 2
        let group2Item1 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                                                                    heightDimension: .fractionalHeight(1)))
        group2Item1.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        let group2 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                           heightDimension: .fractionalHeight(1/3)),
                                                        subitems: [group2Item1])
        group2.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        
        // MARK: Container group
        let containerGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                                 heightDimension: .absolute(600)),
                                                              subitems: [item, group1, group2])
        let section = NSCollectionLayoutSection(group: containerGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error with connection",
                                      message: "Trouble with internet",
                                      preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: "Try again", style: .default) {_ in
            self.viewModel?.refreshNews()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(tryAgainAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
// MARK: UICollectionViewDataSource
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
        print(indexPath)
        return cell
    }
    
}
// MARK: UICollectionViewDelegate
extension NewsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.selectItemAt(indexPath: indexPath)
        performSegue(withIdentifier: SegueIdentifier.detail, sender: nil)
    }
}
// MARK: UIScrollViewDelegate
extension NewsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        guard offsetY > contentHeight - scrollView.frame.height * 1.1 else { return }
        DispatchQueue.main.async {
            self.viewModel?.fetchNextPage()
        }
    }
}
