//
//  PageViewController.swift
//  ImageList
//
//  Created by Дмитрий М. Головин on 04.07.2022.
//

import UIKit

final class PageViewController: UIViewController {

    var pages: [UIViewController] = [] {
        didSet {
            if pages.count > 1 {
                pageControl.numberOfPages = pages.count
            } else {
                hidePageControl()
            }
            pageViewController.dataSource = pages.count > 1 ? self : nil
        }
    }

    private var currentPageIndex: Int {
        guard
            let viewControllers = pageViewController.viewControllers,
            let first = viewControllers.first,
            let index = pages.firstIndex(of: first)
        else {
            return 0
        }
        return index
    }

    // MARK: - UI Properties
    
    private lazy var pageViewController: UIPageViewController = {
        let viewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.dataSource = self
        viewController.delegate = self
        return viewController
    }()

    private lazy var pagesView: UIView = {
        pageViewController.view
    }()

    private lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.pageIndicatorTintColor = .gray
        view.currentPageIndicatorTintColor = .black
        view.addTarget(self, action: #selector(didTapOnPageControl), for: .valueChanged)
        return view
    }()

    // MARK: - ViewController Life Cycle

    override func loadView() {
        view = UIView()
        setupView()
        makeConstraints()
    }
    
    // MARK: - Managing the UIPageViewController

    func setStartPage(pageIndex: Int) {
        guard let page = page(for: pageIndex) else { return }
        pageViewController.setViewControllers(
            [page],
            direction: .forward,
            animated: true
        )
        pageControl.currentPage = pageIndex
    }

    func enableTransitioning() {
        pageViewController.dataSource = pages.count > 1 ? self : nil
    }

    func disableTransitioning() {
        pageViewController.dataSource = nil
    }

    func showPageControl() {
        pageControl.isHidden = false
    }

    func hidePageControl() {
        pageControl.isHidden = true
    }

    // MARK: - Setup View
    
    private func setupView() {
        addChild(pageViewController)
        view.addSubview(pagesView)
        pageViewController.didMove(toParent: self)
        view.backgroundColor = .white
        view.addSubview(pageControl)
    }

    private func makeConstraints() {
        NSLayoutConstraint.activate([
            pagesView.topAnchor.constraint(equalTo: view.topAnchor),
            pagesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagesView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    // MARK: - Actions

    @objc
    private func didTapOnPageControl(sender: UIPageControl) {
        pageViewController.setViewControllers(
            [pages[pageControl.currentPage]],
            direction: sender.currentPage > currentPageIndex ? .forward : .reverse,
            animated: true,
            completion: nil
        )
    }
}

// MARK: - UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        return page(for: index + 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        return page(for: index - 1)
    }

    private func page(for index: Int) -> UIViewController? {
        pages.indices.contains(index) ? pages[index] : nil
    }
}

// MARK: - UIPageViewControllerDelegate

extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        pageControl.currentPage = currentPageIndex
    }
}
