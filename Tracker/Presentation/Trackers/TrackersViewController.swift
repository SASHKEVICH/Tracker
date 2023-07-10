//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.03.2023.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject, AlertPresenterServiceDelegate {
	var presenter: TrackersViewPresenterFullProtocol? { get set }
    func didRecieveTrackers()
    func showPlaceholderViewForCurrentDay()
    func showPlaceholderViewForEmptySearch()
    func shouldHidePlaceholderView(_ isHide: Bool)
}

typealias TrackersViewPresenterFullProtocol =
	TrackersViewPresenterProtocol
	& TrackersViewPresetnerCollectionViewProtocol
	& TrackersViewPresetnerSearchControllerProtocol

final class TrackersViewController: UIViewController {
	var presenter: TrackersViewPresenterFullProtocol?

    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout())

	private let searchController = UISearchController()
	private let collectionPlaceholderView = TrackerPlaceholderView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .Dynamic.whiteDay
        
        presenter?.viewDidLoad()
        
        setupCollectionView()
        setupNavigationItem()
        setupPlaceholderView()
    }
}

// MARK: - TrackersViewControllerProtocol
extension TrackersViewController: TrackersViewControllerProtocol {
	func didRecieveTrackers() {
		collectionView.reloadData()
	}
}

// MARK: - Setup PlaceholderView
extension TrackersViewController {
    func showPlaceholderViewForCurrentDay() {
		collectionPlaceholderView.set(state: .emptyTrackersForDay)
        shouldHidePlaceholderView(false)
    }
    
    func showPlaceholderViewForEmptySearch() {
		collectionPlaceholderView.set(state: .emptyTrackersSearch)
        shouldHidePlaceholderView(false)
    }
    
    func shouldHidePlaceholderView(_ isHide: Bool) {
        UIView.transition(
            with: collectionPlaceholderView,
            duration: 0.3,
            options: .transitionCrossDissolve
        ) { [weak self] in
			self?.collectionPlaceholderView.isHidden = isHide
        }
    }
    
    private func setupPlaceholderView() {
		collectionPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
		view.insertSubview(self.collectionPlaceholderView, aboveSubview: collectionView)
        
        NSLayoutConstraint.activate([
			collectionPlaceholderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionPlaceholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionPlaceholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionPlaceholderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
		collectionPlaceholderView.isHidden = true
    }
}

// MARK: - Setup SearchController
extension TrackersViewController {
    func setupSearchController() {
        searchController.searchResultsUpdater = presenter?.searchControllerHelper
        searchController.searchBar.delegate = presenter?.searchControllerHelper
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

// MARK: Alert Presenter Delegate
extension TrackersViewController: AlertPresenterServiceDelegate {
    func didRecieve(alert: UIAlertController) {
        present(alert, animated: true)
    }
}

// MARK: - Setup CollectionView
private extension TrackersViewController {
	func setupCollectionView() {
		layoutCollectionView()

		collectionView.delegate = presenter?.collectionHelper
		collectionView.dataSource = presenter?.collectionHelper
		collectionView.register(
			TrackersCollectionViewCell.self,
			forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier)
		collectionView.register(
			TrackersCollectionSectionHeader.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: TrackersCollectionSectionHeader.identifier)
	}

	func layoutCollectionView() {
		collectionView.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(collectionView)
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
}

// MARK: - Callbacks
private extension TrackersViewController {
	@objc
	func didTapAddTracker() {
		let vc = TrackerTypeViewController()
		let router = TrackerTypeRouter(viewController: vc)
		let presenter = TrackerTypePresenter(router: router)

		vc.presenter = presenter

		self.present(vc, animated: true)
	}

	@objc
	func didCurrentDateValueChanged(_ datePicker: UIDatePicker) {
		presenter?.requestTrackers(for: datePicker.date)
	}
}
