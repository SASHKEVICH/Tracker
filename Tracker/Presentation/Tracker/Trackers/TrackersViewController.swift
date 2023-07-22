//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.03.2023.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject, AlertPresenterServiceDelegate {
    var presenter: TrackersViewPresenterFullProtocol? { get set }
    func showPlaceholderViewForCurrentDay()
    func showPlaceholderViewForEmptySearch()
    func shouldHidePlaceholderView(_ isHide: Bool)
}

protocol TrackersViewControllerFetchingProtocol {
    func didRecieveTrackers()
    func insertItems(at: [IndexPath])
    func deleteItems(at: [IndexPath])
    func moveItems(at: IndexPath, to: IndexPath)
    func reloadItems(at: [IndexPath])
    func didChangeContentAnimated(operations: [BlockOperation])

    func insertSections(at: IndexSet)
    func deleteSections(at: IndexSet)
    func reloadSections(at: IndexSet)
}

typealias TrackersViewControllerFullProtocol = TrackersViewControllerProtocol & TrackersViewControllerFetchingProtocol

final class TrackersViewController: UIViewController {
    var presenter: TrackersViewPresenterFullProtocol?

    private lazy var trackersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self.presenter?.collectionHelper
        collectionView.dataSource = self.presenter?.collectionHelper
        collectionView.bounces = true
        collectionView.isScrollEnabled = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        collectionView.backgroundColor = .Dynamic.whiteDay
        collectionView.register(
            TrackersCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            TrackersCollectionSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackersCollectionSectionHeader.reuseIdentifier
        )
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

    private lazy var filterButton: TrackerCustomButton = {
        let title = R.string.localizable.trackersFilterButtonTitle()
        let button = TrackerCustomButton(state: .filter, title: title)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.didTapFilterButton), for: .touchUpInside)
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current
        datePicker.addTarget(self, action: #selector(self.didCurrentDateValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()

    private let collectionPlaceholderView = {
        let view = TrackerPlaceholderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private var selectedFilter: TrackerCategory?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .Dynamic.whiteDay

        addSubviews()
        addConstraints()
        setupNavigationItem()

        presenter?.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.analyticsService.didOpenMainScreen()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter?.analyticsService.didCloseMainScreen()
    }
}

// MARK: - TrackersViewControllerProtocol

extension TrackersViewController: TrackersViewControllerProtocol {
    func showPlaceholderViewForCurrentDay() {
        collectionPlaceholderView.set(state: .emptyTrackersForDay)
        shouldHidePlaceholderView(false)
    }

    func showPlaceholderViewForEmptySearch() {
        collectionPlaceholderView.set(state: .emptyTrackersSearch)
        shouldHidePlaceholderView(false)
    }

    func shouldHidePlaceholderView(_ shouldHide: Bool) {
        UIView.transition(
            with: collectionPlaceholderView,
            duration: 0.3,
            options: .transitionCrossDissolve
        ) { [weak self] in
            self?.collectionPlaceholderView.isHidden = shouldHide
        }
    }
}

// MARK: - TrackersViewControllerFetchingProtocol

extension TrackersViewController: TrackersViewControllerFetchingProtocol {
    func insertSections(at: IndexSet) {
        trackersCollectionView.insertSections(at)
    }

    func deleteSections(at: IndexSet) {
        trackersCollectionView.deleteSections(at)
    }

    func reloadSections(at: IndexSet) {
        trackersCollectionView.reloadSections(at)
    }

    func insertItems(at: TrackersCollectionCellIndices) {
        trackersCollectionView.insertItems(at: at)
    }

    func deleteItems(at: TrackersCollectionCellIndices) {
        trackersCollectionView.deleteItems(at: at)
    }

    func moveItems(at: IndexPath, to: IndexPath) {
        trackersCollectionView.moveItem(at: at, to: to)
    }

    func reloadItems(at: TrackersCollectionCellIndices) {
        trackersCollectionView.reloadItems(at: at)
    }

    func didChangeContentAnimated(operations: [BlockOperation]) {
        trackersCollectionView.performBatchUpdates({
            operations.forEach { $0.start() }
        }, completion: { [weak self] _ in
            self?.presenter?.eraseOperations()
        })
    }

    func didRecieveTrackers() {
        trackersCollectionView.reloadData()
    }
}

// MARK: - TrackerFilterViewControllerDelegate

extension TrackersViewController: TrackerFilterViewControllerDelegate {
    func setCurrentDate() {
        datePicker.date = Date()
    }

    func didSelectFilter(category: TrackerCategory) {
        selectedFilter = category
    }
}

// MARK: - Alert Presenter Delegate

extension TrackersViewController: AlertPresenterServiceDelegate {
    func didRecieve(alert: UIAlertController) {
        present(alert, animated: true)
    }
}

private extension TrackersViewController {
    func addSubviews() {
        view.addSubview(trackersCollectionView)
        view.addSubview(filterButton)
        view.insertSubview(collectionPlaceholderView, aboveSubview: filterButton)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            collectionPlaceholderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionPlaceholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionPlaceholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionPlaceholderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

// MARK: - Setup Navigation Item

private extension TrackersViewController {
    func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = R.string.localizable.trackersNavigationItemTitle()
        navigationItem.searchController = searchController
        definesPresentationContext = true

        setupLeftBarButtonItem()
        setupRightBarButtonItem()
    }

    func setupLeftBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.MainScreen.addTracker,
            style: .plain,
            target: self,
            action: #selector(didTapAddTracker)
        )
        navigationItem.leftBarButtonItem?.tintColor = .Dynamic.blackDay
    }

    func setupRightBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
}

// MARK: - Actions

private extension TrackersViewController {
    @objc
    func didTapAddTracker() {
        presenter?.analyticsService.didTapAddTracker()
        presenter?.navigateToTrackerTypeScreen()
    }

    @objc
    func didCurrentDateValueChanged(_ datePicker: UIDatePicker) {
        presenter?.requestTrackers(for: datePicker.date)
    }

    @objc
    func didTapFilterButton() {
        presenter?.navigateToFilterScreen(chosenDate: datePicker.date, selectedFilter: selectedFilter)
    }
}
