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

final class TrackersViewController: UIViewController {
	var presenter: TrackersViewPresenterFullProtocol?
	
	private lazy var trackersCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.delegate = self.presenter?.collectionHelper
		collectionView.dataSource = self.presenter?.collectionHelper
		collectionView.register(
			TrackersCollectionViewCell.self,
			forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier)
		collectionView.register(
			TrackersCollectionSectionHeader.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: TrackersCollectionSectionHeader.reuseIdentifier)
		return collectionView
	}()
	
	private lazy var searchController: UISearchController = {
		let search = UISearchController()
		search.searchResultsUpdater = self.presenter?.searchControllerHelper
		search.searchBar.delegate = self.presenter?.searchControllerHelper
		search.obscuresBackgroundDuringPresentation = false
		search.searchBar.placeholder = R.string.localizable.trackersSearchControllerPlaceholder()
		return search
	}()
	
	private let collectionPlaceholderView = {
		let view = TrackerPlaceholderView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = .Dynamic.whiteDay

		self.addSubviews()
		self.addConstraints()
		self.setupNavigationItem()

		self.presenter?.viewDidLoad()
    }
}

// MARK: - TrackersViewControllerProtocol
extension TrackersViewController: TrackersViewControllerProtocol {
	func didRecieveTrackers() {
		self.trackersCollectionView.reloadData()
	}
}

// MARK: - Setup PlaceholderView
extension TrackersViewController {
    func showPlaceholderViewForCurrentDay() {
		self.collectionPlaceholderView.set(state: .emptyTrackersForDay)
		self.shouldHidePlaceholderView(false)
    }
    
    func showPlaceholderViewForEmptySearch() {
		self.collectionPlaceholderView.set(state: .emptyTrackersSearch)
		self.shouldHidePlaceholderView(false)
    }
    
    func shouldHidePlaceholderView(_ shouldHide: Bool) {
        UIView.transition(
			with: self.collectionPlaceholderView,
            duration: 0.3,
            options: .transitionCrossDissolve
        ) { [weak self] in
			self?.collectionPlaceholderView.isHidden = shouldHide
        }
    }
}

// MARK: - Alert Presenter Delegate
extension TrackersViewController: AlertPresenterServiceDelegate {
    func didRecieve(alert: UIAlertController) {
		self.present(alert, animated: true)
    }
}

private extension TrackersViewController {
	func addSubviews() {
		self.view.addSubview(self.trackersCollectionView)
		self.view.insertSubview(self.collectionPlaceholderView, aboveSubview: self.trackersCollectionView)
	}

	func addConstraints() {
		NSLayoutConstraint.activate([
			trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])

		NSLayoutConstraint.activate([
			collectionPlaceholderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionPlaceholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionPlaceholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionPlaceholderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
}

// MARK: - Setup Navigation Item
private extension TrackersViewController {
	func setupNavigationItem() {
		self.navigationItem.largeTitleDisplayMode = .always
		self.navigationItem.title = R.string.localizable.trackersNavigationItemTitle()
		self.navigationItem.searchController = self.searchController
		self.definesPresentationContext = true
		
		self.setupLeftBarButtonItem()
		self.setupRightBarButtonItem()
	}

	func setupLeftBarButtonItem() {
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(
			image: UIImage.MainScreen.addTracker,
			style: .plain,
			target: self,
			action: #selector(self.didTapAddTracker))
		self.navigationItem.leftBarButtonItem?.tintColor = .Dynamic.blackDay
	}

	func setupRightBarButtonItem() {
		let datePicker = UIDatePicker(frame: .zero)
		datePicker.translatesAutoresizingMaskIntoConstraints = false
		datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
		datePicker.preferredDatePickerStyle = .compact
		datePicker.datePickerMode = .date
		datePicker.locale = Locale.current
		datePicker.addTarget(self, action: #selector(self.didCurrentDateValueChanged(_:)), for: .valueChanged)
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
	}
}

// MARK: - Actions
private extension TrackersViewController {
	@objc
	func didTapAddTracker() {
		self.presenter?.navigateToTrackerTypeScreen()
	}

	@objc
	func didCurrentDateValueChanged(_ datePicker: UIDatePicker) {
		self.presenter?.requestTrackers(for: datePicker.date)
	}
}
