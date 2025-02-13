//
//  UserListViewModel.swift
//  UIKitPaginationDemo
//
//  Created by BERKAY DISLI on 13.02.2025.
//

import Foundation

// MARK: - ViewModel & Delegate Protocol
protocol UserListViewModelDelegate: AnyObject {
    func didReceiveUsers()
    func didFailWithError(_ error: Error)
    func loadingStateChanged(isLoading: Bool)
}

protocol UserListViewModelProtocol {
    var delegate: UserListViewModelDelegate? { get set }
    var users: [User] { get }
    var isEmpty: Bool { get }
    
    func fetchInitialData()
    func fetchNextPage(isInitial: Bool)
    func loadMoreIfNeeded(currentIndexPath: IndexPath)
}

final class UserListViewModel: UserListViewModelProtocol {
    private let paginationManager = PaginationManager<User>()
    private let networkQueue = DispatchQueue(label: "com.userlist.network", qos: .userInitiated)
    
    weak var delegate: UserListViewModelDelegate?
    
    var users: [User] { paginationManager.currentItems }
    var isEmpty: Bool { paginationManager.currentItems.isEmpty }
    
    func fetchInitialData() {
        paginationManager.reset()
        fetchNextPage(isInitial: true)
    }
    
    func fetchNextPage(isInitial: Bool = false) {
        guard paginationManager.canLoadMore else { return }
        
        networkQueue.async { [weak self] in
            
            if isInitial {
                self?.delegate?.loadingStateChanged(isLoading: true)
            }
            
            self?.paginationManager.loadNextPage { page in
                UserEndpoint.getUsers(page: page)
            } completion: { result in
                DispatchQueue.main.async {
                    if isInitial {
                        self?.delegate?.loadingStateChanged(isLoading: false)
                    }
                    
                    switch result {
                    case .success:
                        self?.delegate?.didReceiveUsers()
                    case .failure(let error):
                        self?.delegate?.didFailWithError(error)
                    }
                }
            }
        }
    }
    
    func loadMoreIfNeeded(currentIndexPath: IndexPath) {
        guard currentIndexPath.row == users.count - 1 else { return }
        fetchNextPage()
    }
}
