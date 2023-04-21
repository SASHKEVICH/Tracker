//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.03.2023.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject, AlertPresenterServiceDelegate {
    var presenter: TrackersViewPresenterProtocol? { get set }
    var isPlaceholderViewHidden: Bool { get set }
    func didRecieveTrackers(indexPaths: [IndexPath]?)
    func showPlaceholderViewForCurrentDay()
    func showPlaceholderViewForEmptySearch()
    func showOrHidePlaceholderView(isHide: Bool)
}

final class TrackersViewController: UIViewController, TrackersViewControllerProtocol {
    private var collectionView: UICollectionView?
    private var placeholderImage: UIImage?
    private var placeholderText: String?
    private var searchController: UISearchController?
    private var collectionPlaceholderView: CollectionPlaceholderView?
    
    private var currentDate: Date = Date()
    
    var presenter: TrackersViewPresenterProtocol?
    
    var isPlaceholderViewHidden: Bool = true {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter?.requestTrackers(for: currentDate)
    }
    
    func didRecieveTrackers(indexPaths: [IndexPath]?) {
        collectionView?.reloadData()
    }
}

// MARK: - Setup CollectionView
private extension TrackersViewController {
    func setupCollectionView() {
        layoutCollectionView()
        
        collectionView?.delegate = presenter?.collectionHelper
        collectionView?.dataSource = presenter?.collectionHelper
        collectionView?.register(
            TrackersCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier)
        collectionView?.register(
            TrackersCollectionSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackersCollectionSectionHeader.identifier)
    }
    
    func layoutCollectionView() {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .trackerWhiteDay
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView = collectionView

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
        setupSearchController()
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
        datePicker.addTarget(self, action: #selector(didCurrentDateValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    @objc
    func didTapAddTracker() {
        let vc = ChooseTrackerTypeViewController()
        present(vc, animated: true)
    }
    
    @objc
    func didCurrentDateValueChanged(_ datePicker: UIDatePicker) {
        presenter?.currentDate = datePicker.date
        presenter?.requestTrackers(for: datePicker.date)
    }
}

// MARK: - Setup PlaceholderView
extension TrackersViewController {
    func showPlaceholderViewForCurrentDay() {
        configurePlaceholderView(
            image: UIImage(named: "TrackersCollectionEmptyImage"),
            text: "Что будем отслеживать?")
        showOrHidePlaceholderView(isHide: false)
    }
    
    func showPlaceholderViewForEmptySearch() {
        configurePlaceholderView(
            image: UIImage(named: "TrackersCollectionEmptyTrackersListSearch"),
            text: "Ничего не найдено")
        showOrHidePlaceholderView(isHide: false)
    }
    
    func showOrHidePlaceholderView(isHide: Bool) {
        guard let placeholderView = collectionPlaceholderView else { return }
        UIView.transition(
            with: placeholderView,
            duration: 0.3,
            options: .transitionCrossDissolve
        ) {
            placeholderView.isHidden = isHide
        }
    }
    
    private func configurePlaceholderView(image: UIImage?, text: String) {
        collectionPlaceholderView?.image = image
        collectionPlaceholderView?.text = text
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

// MARK: - Setup SearchController
extension TrackersViewController {
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = presenter?.searchControllerHelper
        searchController.searchBar.delegate = presenter?.searchControllerHelper
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        self.searchController = searchController
    }
}

// MARK: Alert Presenter Delegate
extension TrackersViewController: AlertPresenterServiceDelegate {
    func didRecieve(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
