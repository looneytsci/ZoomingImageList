//
//  ViewController.swift
//  ImageList
//
//  Created by Дмитрий М. Головин on 04.07.2022.
//

import UIKit

final class ViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    // MARK: - UI Properties
    
    private lazy var pageViewController: PageViewController = {
        let viewController = PageViewController()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        return viewController
    }()

    // MARK: - ViewController Life Cycle

    override func loadView() {
        view = UIView()
        setupView()
        makeConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var pages: [ImageZoomViewController] = []
        let images: [UIImage?] = [
            .init(named: "photo1"),
            .init(named: "photo2"),
            .init(named: "photo3"),
            .init(named: "photo4"),
            .init(named: "photo5"),
            .init(named: "photo6"),
        ]
        for image in images {
            let viewController = ImageZoomViewController()
            viewController.setImage(image)
            viewController.delegate = self
            pages.append(viewController)
        }
        pageViewController.pages = pages
        pageViewController.setStartPage(pageIndex: 0)
    }

    // MARK: - Setup View

    private func setupView() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }

    private func makeConstraints() {
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - ImageZoomViewControllerDelegate

extension ViewController: ImageZoomViewControllerDelegate {
    func imageZoomViewControllerDidZoomOut(_ imageZoomViewController: UIViewController) {
        pageViewController.enableTransitioning()
        pageViewController.showPageControl()
    }

    func imageZoomViewControllerWillBeginZoomingIn(_ imageZoomViewController: UIViewController) {
        pageViewController.disableTransitioning()
    }

    func imageZoomViewControllerDidZoomIn(_ imageZoomViewController: UIViewController) {
        pageViewController.hidePageControl()
    }
}
