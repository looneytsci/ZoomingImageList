//
//  ImageZoomViewController.swift
//  ImageList
//
//  Created by Дмитрий М. Головин on 04.07.2022.
//

import UIKit

protocol ImageZoomViewControllerDelegate: AnyObject {
    func imageZoomViewControllerWillBeginZoomingIn(_ imageZoomViewController: UIViewController)

    func imageZoomViewControllerDidZoomOut(_ imageZoomViewController: UIViewController)

    func imageZoomViewControllerDidZoomIn(_ imageZoomViewController: UIViewController)
}

final class ImageZoomViewController: UIViewController {

    weak var delegate: ImageZoomViewControllerDelegate?

    // MARK: - UI Properties
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.minimumZoomScale = 1
        view.maximumZoomScale = 3
        view.delegate = self
        let tapGesure = UITapGestureRecognizer(
            target: self,
            action: #selector(didDoubleTapOnScrollView)
        )
        tapGesure.numberOfTapsRequired = 2
        view.addGestureRecognizer(tapGesure)
        return view
    }()

    // MARK: - ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard scrollView.zoomScale != 1 else { return }
        let zoomRect = getZoomRect(
            origin: .init(x: view.frame.midX, y: view.frame.midY),
            scale: scrollView.maximumZoomScale
        )
        scrollView.zoom(to: zoomRect, animated: false)
    }

    // MARK: - Setup View
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.backgroundColor = .white
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
        ])
    }

    // MARK: - Actions
    
    @objc
    private func didDoubleTapOnScrollView(gesture: UIGestureRecognizer) {
        let location = gesture.location(in: imageView)
        let zoomRect = getZoomRect(origin: location, scale: scrollView.zoomScale)
        scrollView.zoom(to: zoomRect, animated: true)
    }

    private func getZoomRect(
        origin: CGPoint,
        scale: CGFloat
    ) -> CGRect {
        let currentScale = min(scrollView.zoomScale * 2, scrollView.maximumZoomScale)
        let scrollSize = scrollView.frame.size
        if currentScale != scrollView.zoomScale {
            let size = CGSize(
                width: scrollSize.width / scrollView.maximumZoomScale,
                height: scrollSize.height / scrollView.maximumZoomScale
            )
            let origin = CGPoint(
                x: origin.x - size.width / 2,
                y: origin.y - size.height / 2
            )
            return .init(origin: origin, size: size)
        } else {
            return zoomRectForScale(scrollView.zoomScale, center: origin)
        }
    }

    private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        guard scale != 0 else { return .zero }
        let width = imageView.frame.width / scrollView.maximumZoomScale
        let height = imageView.frame.height / scrollView.maximumZoomScale
        let newCenter = scrollView.convert(center, to: imageView)
        let x = newCenter.x - width / 2
        let y = newCenter.y - height / 2
        return CGRect(
            x: x, y: y,
            width: width,
            height: height
        )
    }
}

// MARK: - UIScrollViewDelegate

extension ImageZoomViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale == 1 {
            delegate?.imageZoomViewControllerDidZoomOut(self)
        } else {
            delegate?.imageZoomViewControllerDidZoomIn(self)
        }
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.imageZoomViewControllerWillBeginZoomingIn(self)
    }
}
