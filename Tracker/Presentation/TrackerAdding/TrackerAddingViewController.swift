//
//  TrackerAddingViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import UIKit

protocol TrackerScheduleViewControllerDelegate: AnyObject {
    func dismissTrackerScheduleViewController()
    func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>)
}

protocol TrackerAddingViewControllerProtocol: AnyObject, TrackerScheduleViewControllerDelegate {
    var presenter: TrackerAddingViewPresenterProtocol? { get set }
    var trackerScheduleViewController: TrackerScheduleViewController? { get set }
    func didTapTrackerScheduleCell(_ vc: TrackerScheduleViewController)
    func setViewControllerTitle(_ title: String)
    func showError() -> Bool
    func hideError() -> Bool
    func enableAddButton()
    func disableAddButton()
}

final class TrackerAddingViewController: UIViewController, TrackerAddingViewControllerProtocol {
    private let scrollView = UIScrollView()
    private let contentScrollView = UIView()
    
    private let titleLabel = UILabel()
    
    private let trackerTitleTextField = TrackerTitleTextField()
    private let errorLabel = UILabel()
    
    private let trackerOptionsTableView = UITableView()
    
    private let emojisCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout())
    private let colorsCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout())
    
    private let cancelTrackerButton = TrackerCustomButton(state: .cancel, title: "Отменить")
    private let addTrackerButton = TrackerCustomButton(state: .disabled, title: "Создать")
    
    private var tableViewTopConstraint: NSLayoutConstraint?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var emojisCollectionViewHeightConstraint: NSLayoutConstraint?
    private var colorsCollectionViewHeightConstraint: NSLayoutConstraint?
    
    var presenter: TrackerAddingViewPresenterProtocol?
    var trackerScheduleViewController: TrackerScheduleViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .trackerWhiteDay
        isModalInPresentation = true
        
        setupScrollView()
        setupTitleLabel()
        setupTrackerTitleTextField()
        setupErrorLabel()
        setupTrackerOptionsTableView()
        setupCollectionViews()
        
        presenter?.viewDidLoad()
        trackerOptionsTableView.reloadData()
        emojisCollectionView.reloadData()
        colorsCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard contentScrollView.frame.width != 0 else { return }
        setupCancelAndAddTrackerButton()
        
        tableViewHeightConstraint?.constant = trackerOptionsTableView.contentSize.height
        emojisCollectionViewHeightConstraint?.constant = emojisCollectionView.contentSize.height
        colorsCollectionViewHeightConstraint?.constant = colorsCollectionView.contentSize.height
        
        view.setNeedsLayout()
    }
}

// MARK: - Setup and layout views
private extension TrackerAddingViewController {
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentScrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentScrollView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            contentScrollView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    func setupTitleLabel() {
        contentScrollView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentScrollView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor)
        ])
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .trackerBlackDay
    }
    
    func setupTrackerTitleTextField() {
        contentScrollView.addSubview(trackerTitleTextField)
        trackerTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackerTitleTextField.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor, constant: 16),
            trackerTitleTextField.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor, constant: -16),
            trackerTitleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            trackerTitleTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        trackerTitleTextField.placeholder = "Введите название трекера"
        trackerTitleTextField.delegate = presenter?.textFieldHelper
        trackerTitleTextField.clearButtonMode = .whileEditing
        trackerTitleTextField.addTarget(self, action: #selector(didChangeTrackerTitleTextField(_:)), for: .editingChanged)
    }
    
    func setupErrorLabel() {
        contentScrollView.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: trackerTitleTextField.bottomAnchor, constant: 8),
            errorLabel.heightAnchor.constraint(equalToConstant: 22),
            errorLabel.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
        ])
        
        errorLabel.isHidden = true
        
        errorLabel.text = "Ограничение 38 символов"
        errorLabel.font = .systemFont(ofSize: 17)
        errorLabel.sizeToFit()
        
        errorLabel.textColor = .trackerRed
    }
    
    func setupTrackerOptionsTableView() {
        contentScrollView.addSubview(trackerOptionsTableView)
        trackerOptionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        let tableViewTopConstraint = NSLayoutConstraint(
            item: trackerOptionsTableView,
            attribute: .top,
            relatedBy: .equal,
            toItem: trackerTitleTextField,
            attribute: .bottom,
            multiplier: 1,
            constant: 24)
        
        let tableViewHeightConstraint = NSLayoutConstraint(
            item: trackerOptionsTableView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1,
            constant: 75)
        
        NSLayoutConstraint.activate([
            trackerOptionsTableView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor, constant: 16),
            trackerOptionsTableView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor, constant: -16),
            tableViewTopConstraint,
            tableViewHeightConstraint
        ])
        
        trackerOptionsTableView.dataSource = presenter?.tableViewHelper
        trackerOptionsTableView.delegate = presenter?.tableViewHelper
        trackerOptionsTableView.register(TrackerOptionsTableViewCell.self, forCellReuseIdentifier: TrackerOptionsTableViewCell.identifier)
        trackerOptionsTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        self.tableViewTopConstraint = tableViewTopConstraint
        self.tableViewHeightConstraint = tableViewHeightConstraint
    }
    
    func setupCollectionViews() {
        let emojisCollectionViewHeightConstraint = NSLayoutConstraint(
            item: emojisCollectionView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1,
            constant: 100)
        
        let colorsCollectionViewHeightConstraint = NSLayoutConstraint(
            item: colorsCollectionView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1,
            constant: 100)
        
        contentScrollView.addSubview(emojisCollectionView)
        emojisCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        contentScrollView.addSubview(colorsCollectionView)
        colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojisCollectionView.topAnchor.constraint(equalTo: trackerOptionsTableView.bottomAnchor, constant: 32),
            emojisCollectionView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            emojisCollectionView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
            emojisCollectionViewHeightConstraint,
            
            colorsCollectionView.topAnchor.constraint(equalTo: emojisCollectionView.bottomAnchor, constant: 16),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
            colorsCollectionViewHeightConstraint
        ])
        
        emojisCollectionView.dataSource = presenter?.emojisCollectionViewHelper
        emojisCollectionView.delegate = presenter?.emojisCollectionViewHelper
        emojisCollectionView.register(
            EmojisCollectionViewCell.self,
            forCellWithReuseIdentifier: EmojisCollectionViewCell.identifier)
        emojisCollectionView.register(
            TrackersCollectionSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackersCollectionSectionHeader.identifier)
        
        colorsCollectionView.dataSource = presenter?.colorsCollectionViewHelper
        colorsCollectionView.delegate = presenter?.colorsCollectionViewHelper
        colorsCollectionView.register(
            ColorsCollectionViewCell.self,
            forCellWithReuseIdentifier: ColorsCollectionViewCell.identifier)
        colorsCollectionView.register(
            TrackersCollectionSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackersCollectionSectionHeader.identifier)
        
        self.emojisCollectionViewHeightConstraint = emojisCollectionViewHeightConstraint
        self.colorsCollectionViewHeightConstraint = colorsCollectionViewHeightConstraint
    }
    
    func setupCancelAndAddTrackerButton() {
        contentScrollView.addSubview(addTrackerButton)
        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentScrollView.addSubview(cancelTrackerButton)
        cancelTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        let cellWidth = (contentScrollView.bounds.width - 20 * 2 - 8) / 2
        
        [addTrackerButton, cancelTrackerButton].forEach {
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 60),
                $0.widthAnchor.constraint(equalToConstant: cellWidth)
            ])
        }
        
        NSLayoutConstraint.activate([
            cancelTrackerButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            cancelTrackerButton.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor, constant: 20),
            cancelTrackerButton.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            
            addTrackerButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            addTrackerButton.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor, constant: -20),
            addTrackerButton.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
        ])
        
        cancelTrackerButton.addTarget(self, action: #selector(didTapCancelTrackerButton), for: .touchUpInside)
        addTrackerButton.addTarget(self, action: #selector(didTapAddTrackerButton), for: .touchUpInside)
    }
}

// MARK: - Callbacks
private extension TrackerAddingViewController {
    @objc
    func didTapCancelTrackerButton() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func didTapAddTrackerButton() {
        presenter?.didConfirmAddTracker()
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func didChangeTrackerTitleTextField(_ textField: UITextField) {
        guard let title = textField.text else { return }
        presenter?.didChangeTrackerTitle(title)
    }
}

extension TrackerAddingViewController {
    func setViewControllerTitle(_ title: String) {
        titleLabel.text = title
        titleLabel.sizeToFit()
    }
}

// MARK: - Showing and Hiding error label
extension TrackerAddingViewController {
    func showError() -> Bool {
        guard errorLabel.isHidden else { return errorLabel.isHidden }
        
        errorLabel.isHidden = false
        addTrackerButton.buttonState = .disabled
        tableViewTopConstraint?.constant = 54
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.errorLabel.isHidden = false
        }
        
        return errorLabel.isHidden
    }
    
    func hideError() -> Bool {
        guard !errorLabel.isHidden else { return errorLabel.isHidden }
        
        addTrackerButton.buttonState = .normal
        tableViewTopConstraint?.constant = 24
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.errorLabel.isHidden = true
        }
        
        return errorLabel.isHidden
    }
}

// MARK: - Toggle enabling add tracker button
extension TrackerAddingViewController {
    func enableAddButton() {
        addTrackerButton.buttonState = .normal
    }
    
    func disableAddButton() {
        addTrackerButton.buttonState = .disabled
    }
}

// MARK: - Cells callbacks
extension TrackerAddingViewController {
    func didTapTrackerScheduleCell(_ vc: TrackerScheduleViewController) {
        present(vc, animated: true)
    }
}

// MARK: - TrackerScheduleViewControllerDelegate
extension TrackerAddingViewController: TrackerScheduleViewControllerDelegate {
    func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>) {
        presenter?.didRecieveSelectedTrackerSchedule(weekDays)
        trackerOptionsTableView.reloadData()
    }
    
    func dismissTrackerScheduleViewController() {
        dismiss(animated: true)
    }
}
