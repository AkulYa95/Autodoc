//
//  ViewController.swift
//  AutoNews
//
//  Created by Ярослав Акулов on 23.07.2022.
//

import UIKit

class ChoiceViewController: UIViewController {
    
    var navigationTitle: String {
        return "Auto news"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction private func goToUIKitVC() { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? NewsViewController else { return }
        destinationVC.viewModel = NewsViewControllerViewModel()
    }
}

