//
//  Pagination.swift
//  UIKitPaginationDemo
//
//  Created by BERKAY DISLI on 12.02.2025.
//

import Foundation

struct PaginationState {
    var currentPage: Int
    var isLoading: Bool
    var hasMorePages: Bool
    var itemCount: Int
    
    static let initial = PaginationState(
        currentPage: 1,
        isLoading: false,
        hasMorePages: true,
        itemCount: 0
    )
}

class PaginationManager<T: Codable> {
    private var state: PaginationState = .initial
    private let pageSize: Int
    private var items: [T] = []
    
    init(pageSize: Int = 20) {
        self.pageSize = pageSize
    }
    
    var currentItems: [T] { items }
    var canLoadMore: Bool { state.hasMorePages && !state.isLoading }
    
    func reset() {
        state = .initial
        items = []
    }
    
    func loadNextPage(using apiCall: @escaping (Int) -> EndPoint, completion: @escaping (Result<[T], Error>) -> Void) {
        print("Loading page: \(state.currentPage)")
        guard canLoadMore else { return }
        
        state.isLoading = true
        let endpoint = apiCall(state.currentPage)
        
        APIAgent.shared.run(endpoint) { [weak self] (result: CustomResult<[T]>) in
            guard let self = self else { return }
            
            self.state.isLoading = false
            
            switch result {
            case .success(let newItems):
                if let items = newItems {
                    self.items.append(contentsOf: items)
                    self.state.itemCount += items.count
                    self.state.currentPage += 1
                    self.state.hasMorePages = true /*items.count >= self.pageSize*/
                    completion(.success(self.items))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
