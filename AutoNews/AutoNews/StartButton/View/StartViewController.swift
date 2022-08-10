//
//  ViewController.swift
//  AutoNews
//
//  Created by Ярослав Акулов on 23.07.2022.
//

import UIKit

class StartViewController: UIViewController {
    
    var navigationTitle: String {
        return "Auto news"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.8022577167, green: 0.1396244764, blue: 0.1869231164, alpha: 1)
    }
    
    @IBAction private func goToUIKitVC() {
        performSegue(withIdentifier: SegueIdentifier.collection, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? NewsViewController else { return }
        destinationVC.viewModel = NewsViewControllerViewModel()
    }
}

