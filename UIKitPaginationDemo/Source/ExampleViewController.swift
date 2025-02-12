//
//  ExampleViewController.swift
//  UIKitPaginationDemo
//
//  Created by BERKAY DISLI on 12.02.2025.
//

import Foundation
import UIKit

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let gender: String
    let status: String
}

class ExampleViewController: UIViewController {
    private var collectionView: UICollectionView!
    private let paginationManager = PaginationManager<User>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        self.title = "Users"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        setupCollectionView()
        loadInitialData()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: view.bounds.width - 20, height: 80)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: UserCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadInitialData() {
        paginationManager.reset()
        loadMoreData()
    }
    
    private func loadMoreData() {
        paginationManager.loadNextPage { page in
            return UserEndpoint.getUsers(page: page)
        } completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                self.collectionView.reloadData()
            case .failure(let error):
                print("Error loading data: \(error)")
            }
        }
    }
}

extension ExampleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Check if we're near the end of the content
        let itemsLoaded = paginationManager.currentItems.count
        if indexPath.item == itemsLoaded - 2 { // Load more when 5 items before the end
            loadMoreData()
        }
        
        if let cell = cell as? UserCollectionViewCell {
            cell.animate()
        }
    }
}

extension ExampleViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paginationManager.currentItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.identifier, for: indexPath) as? UserCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let user = paginationManager.currentItems[indexPath.item]
        cell.configure(with: user)
        return cell
    }
}
