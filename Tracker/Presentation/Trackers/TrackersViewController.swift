//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 24.03.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    private var collectionView: UICollectionView?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trackerBackgroundColor
        setupCollectionView()
        setupNavigationItem()
    }
}

// MARK: - CollectionView Layout
extension TrackersViewController {
    func setupCollectionView() {
        layoutCollectionView()
    }
    
    private func layoutCollectionView() {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .trackerBackgroundColor
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
extension TrackersViewController {
    func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Трекеры"
        setupLeftBarButtonItem()
        setupRightBarButtonItem()
    }
    
    private func setupLeftBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "AddTrackerIcon"),
            style: .plain,
            target: self,
            action: #selector(didTapAddTracker))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    private func setupRightBarButtonItem() {
        guard let navigationController = navigationController else { return }
        let datePickerView = setupDatePickerView()
        let navigationBar = navigationController.navigationBar
        navigationBar.addSubview(datePickerView)
        
        NSLayoutConstraint.activate([
            datePickerView.widthAnchor.constraint(equalToConstant: 100),
            datePickerView.topAnchor.constraint(equalTo: navigationBar.topAnchor),
            datePickerView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -16),
            datePickerView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func setupDatePickerView() -> UIView {
        let datePickerView = UIView(frame: .zero)
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        
        datePickerView.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: datePickerView.topAnchor, constant: 52),
            datePicker.leadingAnchor.constraint(equalTo: datePickerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: datePickerView.trailingAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        return datePickerView
    }
    
    @objc
    private func didTapAddTracker() {
        print("Add Tracker")
    }
}
