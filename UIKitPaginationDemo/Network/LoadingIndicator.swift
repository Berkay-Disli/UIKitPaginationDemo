//
//  LoadingIndicatorPresentable.swift
//  UIKitPaginationDemo
//
//  Created by BERKAY DISLI on 13.02.2025.
//

import UIKit

protocol LoadingIndicatorPresentable where Self: UIViewController {
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

extension LoadingIndicatorPresentable {
    func showLoadingIndicator() {
        DispatchQueue.main.async {
            let indicatorView = LoadingIndicatorView()
            self.view.addSubview(indicatorView)
            indicatorView.frame = self.view.bounds
            indicatorView.animate()
        }
    }
    
    func hideLoadingIndicator() {
        view.subviews.forEach { subview in
            if let indicator = subview as? LoadingIndicatorView {
                indicator.removeFromSuperview()
            }
        }
    }
}

final class LoadingIndicatorView: UIView {
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        return indicator
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 12
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(backgroundView)
        backgroundView.addSubview(activityIndicator)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 80),
            backgroundView.heightAnchor.constraint(equalTo: backgroundView.widthAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        ])
    }
    
    func animate() {
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    func stop() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
