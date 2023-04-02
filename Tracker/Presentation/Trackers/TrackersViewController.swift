//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.03.2023.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject {
    var presenter: TrackersViewPresenterProtocol? { get set }
    var isPlaceholderViewHidden: Bool { get set }
}

final class TrackersViewController: UIViewController, TrackersViewControllerProtocol {
    private var collectionView: UICollectionView?
    private var collectionPlaceholderView: CollectionPlaceholderView?
    private var placeholderImage: UIImage?
    private var placeholderText: String?
    
    var presenter: TrackersViewPresenterProtocol?
    
    var isPlaceholderViewHidden: Bool = false {
        didSet {
            collectionPlaceholderView?.isHidden = isPlaceholderViewHidden
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trackerWhiteDay
        setupCollectionView()
        setupNavigationItem()
        setupPlaceholderView()
    }
}

// MARK: - CollectionView Layout
private extension TrackersViewController {
    func setupCollectionView() {
        layoutCollectionView()
    }
    
    func layoutCollectionView() {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .trackerWhiteDay
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView = collectionView

        guard let collectionView = self.collectionView else { return }
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - Setup Navigation Item
private extension TrackersViewController {
    func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Трекеры"
        setupLeftBarButtonItem()
        setupRightBarButtonItem()
    }
    
    func setupLeftBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "AddTrackerIcon"),
            style: .plain,
            target: self,
            action: #selector(didTapAddTracker))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    func setupRightBarButtonItem() {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    @objc
    func didTapAddTracker() {
        print("Add Tracker")
    }
}

extension TrackersViewController {
    func configurePlaceholderView(image: UIImage?, text: String) {
        placeholderImage = image
        placeholderText = text
    }
    
    private func setupPlaceholderView() {
        guard let collectionView = self.collectionView else { return }
        let placeholderView = CollectionPlaceholderView(frame: .zero)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(placeholderView, aboveSubview: collectionView)
        
        NSLayoutConstraint.activate([
            placeholderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        placeholderView.isHidden = isPlaceholderViewHidden
        placeholderView.image = placeholderImage
        placeholderView.text = placeholderText
        self.collectionPlaceholderView = placeholderView
    }
}
