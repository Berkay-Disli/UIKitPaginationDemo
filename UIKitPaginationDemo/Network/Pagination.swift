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

typealias APIResult<T: Codable> = CustomResult<APIResponse<[T]>>

class PaginationManager<T: Codable> {
    private var state: PaginationState = .initial
    private let pageSize: Int
    private var items: [T] = []
    private var totalPages: Int?
    
    init(pageSize: Int = 20) {
        self.pageSize = pageSize
    }
    
    var currentItems: [T] { items }
    var canLoadMore: Bool {
        if let totalPages {
            return state.currentPage <= totalPages && !state.isLoading
        }
        return state.hasMorePages && !state.isLoading
    }
    
    func reset() {
        state = .initial
        items = []
        totalPages = nil
    }
    
    func loadNextPage(using apiCall: @escaping (Int) -> EndPoint, completion: @escaping (Result<[T], Error>) -> Void) {
        print("🟡 [PaginationManager] Loading Page: \(state.currentPage)")
        guard canLoadMore else { return }
        
        state.isLoading = true
        let endpoint = apiCall(state.currentPage)
        
        APIAgent.shared.run(endpoint) { [weak self] (result: APIResult<T>) in
            guard let self else { return }
            
            self.state.isLoading = false
            
            switch result {
            case .success(let response):
                if let items = response?.data {
                    self.items.append(contentsOf: items)
                    self.state.itemCount += items.count
                    self.state.currentPage += 1
                    
                    if let totalPages = response?.totalPages {
                        self.totalPages = totalPages
                        self.state.hasMorePages = self.state.currentPage <= totalPages
                    } else {
                        self.state.hasMorePages = !items.isEmpty
                    }
                    
                    completion(.success(self.items))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
