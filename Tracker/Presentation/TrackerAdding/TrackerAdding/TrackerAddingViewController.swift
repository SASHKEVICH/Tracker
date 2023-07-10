//
//  TrackerAddingViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import UIKit

protocol TrackerAddingViewControllerProtocol: AnyObject, TrackerScheduleViewControllerDelegate, TrackerCategoryViewControllerDelegate {
    var presenter: TrackerAddingViewPresenterProtocol? { get set }
	var emptyTap: (() -> Void)? { get set }
    func setViewControllerTitle(_ title: String)
    func showError() -> Bool
    func hideError() -> Bool
    func enableAddButton()
    func disableAddButton()
}

final class TrackerAddingViewController: UIViewController {
	var presenter: TrackerAddingViewPresenterProtocol?
	var emptyTap: (() -> Void)?
	
	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()
	
	private let contentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .Medium.big
		label.textColor = .Dynamic.blackDay
		return label
	}()
	
	private lazy var trackerTitleTextField: TrackerCustomTextField = {
		let textField = TrackerCustomTextField()
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.placeholder = "Введите название трекера"
		textField.delegate = self.presenter?.textFieldHelper
		textField.clearButtonMode = .whileEditing
		textField.addTarget(self, action: #selector(self.didChangeTrackerTitleTextField(_:)), for: .editingChanged)
		return textField
	}()
	
	private let errorLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.isHidden = true
		label.text = "Ограничение 38 символов"
		label.font = .Regular.medium
		label.textColor = .Static.red
		label.sizeToFit()
		return label
	}()
	
	private lazy var trackerOptionsTableView: UITableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.dataSource = self.presenter?.tableViewHelper
		tableView.delegate = self.presenter?.tableViewHelper
		tableView.register(
			TrackerOptionsTableViewCell.self,
			forCellReuseIdentifier: TrackerOptionsTableViewCell.reuseIdentifier
		)
		return tableView
	}()
	
	private lazy var emojisCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.dataSource = self.presenter?.emojisCollectionViewHelper
		collectionView.delegate = self.presenter?.emojisCollectionViewHelper
		collectionView.register(
			EmojisCollectionViewCell.self,
			forCellWithReuseIdentifier: EmojisCollectionViewCell.reuseIdentifier
		)
		collectionView.register(
			TrackersCollectionSectionHeader.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: TrackersCollectionSectionHeader.identifier
		)
		return collectionView
	}()
	
	private lazy var colorsCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.dataSource = presenter?.colorsCollectionViewHelper
		collectionView.delegate = presenter?.colorsCollectionViewHelper
		collectionView.register(
			ColorsCollectionViewCell.self,
			forCellWithReuseIdentifier: ColorsCollectionViewCell.reuseIdentifier
		)
		collectionView.register(
			TrackersCollectionSectionHeader.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: TrackersCollectionSectionHeader.identifier
		)
		return collectionView
	}()
	
	private lazy var cancelTrackerButton: TrackerCustomButton = {
		let button = TrackerCustomButton(state: .cancel, title: "Отменить")
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(self.didTapCancelTrackerButton), for: .touchUpInside)
		return button
	}()
	
	private lazy var addTrackerButton: TrackerCustomButton = {
		let button = TrackerCustomButton(state: .disabled, title: "Создать")
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(self.didTapAddTrackerButton), for: .touchUpInside)
		return button
	}()
    
	private lazy var tableViewTopConstraint = NSLayoutConstraint(
		item: self.trackerOptionsTableView,
		attribute: .top,
		relatedBy: .equal,
		toItem: self.trackerTitleTextField,
		attribute: .bottom,
		multiplier: 1,
		constant: 24)

    private lazy var tableViewHeightConstraint = NSLayoutConstraint(
		item: self.trackerOptionsTableView,
		attribute: .height,
		relatedBy: .equal,
		toItem: nil,
		attribute: .height,
		multiplier: 1,
		constant: 75)

    private lazy var emojisCollectionViewHeightConstraint = NSLayoutConstraint(
		item: self.emojisCollectionView,
		attribute: .height,
		relatedBy: .equal,
		toItem: nil,
		attribute: .height,
		multiplier: 1,
		constant: 100)

    private lazy var colorsCollectionViewHeightConstraint = NSLayoutConstraint(
		item: self.colorsCollectionView,
		attribute: .height,
		relatedBy: .equal,
		toItem: nil,
		attribute: .height,
		multiplier: 1,
		constant: 100)

    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = .Dynamic.whiteDay
		self.isModalInPresentation = true
        
		self.addSubviews()
		self.addConstraints()
		self.addGestureRecognizers()
        
		self.presenter?.viewDidLoad()
		self.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard contentView.frame.width != 0 else { return }
		self.addConstraintsToButtons()
        
		self.tableViewHeightConstraint.constant = self.trackerOptionsTableView.contentSize.height
		self.emojisCollectionViewHeightConstraint.constant = self.emojisCollectionView.contentSize.height
		self.colorsCollectionViewHeightConstraint.constant = self.colorsCollectionView.contentSize.height
        
		self.view.setNeedsLayout()
    }
}

// MARK: - TrackerAddingViewControllerProtocol
extension TrackerAddingViewController: TrackerAddingViewControllerProtocol {
    func setViewControllerTitle(_ title: String) {
        titleLabel.text = title
        titleLabel.sizeToFit()
    }

	func showError() -> Bool {
		guard errorLabel.isHidden else { return errorLabel.isHidden }

		errorLabel.isHidden = false
		addTrackerButton.buttonState = .disabled
		tableViewTopConstraint.constant = 54

		return shouldHideErrorLabelWithAnimation(false)
	}

	func hideError() -> Bool {
		guard !errorLabel.isHidden else { return errorLabel.isHidden }

		addTrackerButton.buttonState = .normal
		tableViewTopConstraint.constant = 24

		return shouldHideErrorLabelWithAnimation(true)
	}

	func enableAddButton() {
		addTrackerButton.buttonState = .normal
	}

	func disableAddButton() {
		addTrackerButton.buttonState = .disabled
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

// MARK: - TrackerCategoryViewControllerDelegate
extension TrackerAddingViewController: TrackerCategoryViewControllerDelegate {
	func didRecieveCategory(_ category: TrackerCategory) {
		presenter?.didRecieveSelectedCategory(category)
		trackerOptionsTableView.reloadData()
	}
}

// MARK: - Layout views
private extension TrackerAddingViewController {
	func addSubviews() {
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)

		contentView.addSubview(titleLabel)
		contentView.addSubview(trackerTitleTextField)
		contentView.addSubview(errorLabel)
		contentView.addSubview(trackerOptionsTableView)
		contentView.addSubview(emojisCollectionView)
		contentView.addSubview(colorsCollectionView)
		contentView.addSubview(addTrackerButton)
		contentView.addSubview(cancelTrackerButton)
	}

	func addConstraints() {
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

			contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
			contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

			contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
		])

		NSLayoutConstraint.activate([
			errorLabel.topAnchor.constraint(equalTo: trackerTitleTextField.bottomAnchor, constant: 8),
			errorLabel.heightAnchor.constraint(equalToConstant: 22),
			errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
		])

		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
			titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
		])

		NSLayoutConstraint.activate([
			trackerTitleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			trackerTitleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			trackerTitleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
			trackerTitleTextField.heightAnchor.constraint(equalToConstant: 75)
		])

		NSLayoutConstraint.activate([
			trackerOptionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			trackerOptionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			tableViewTopConstraint,
			tableViewHeightConstraint
		])

		NSLayoutConstraint.activate([
			emojisCollectionView.topAnchor.constraint(equalTo: trackerOptionsTableView.bottomAnchor, constant: 32),
			emojisCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			emojisCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			emojisCollectionViewHeightConstraint,
		])

		NSLayoutConstraint.activate([
			colorsCollectionView.topAnchor.constraint(equalTo: emojisCollectionView.bottomAnchor, constant: 16),
			colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			colorsCollectionViewHeightConstraint
		])
	}

	func addConstraintsToButtons() {
		let cellWidth = (contentView.bounds.width - 20 * 2 - 8) / 2

		[addTrackerButton, cancelTrackerButton].forEach {
			NSLayoutConstraint.activate([
				$0.heightAnchor.constraint(equalToConstant: 60),
				$0.widthAnchor.constraint(equalToConstant: cellWidth)
			])
		}

		NSLayoutConstraint.activate([
			cancelTrackerButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
			cancelTrackerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			cancelTrackerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
		])

		NSLayoutConstraint.activate([
			addTrackerButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
			addTrackerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			addTrackerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
		])
	}

	func addGestureRecognizers() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
		tap.cancelsTouchesInView = false
		tap.numberOfTapsRequired = 1
		self.view.addGestureRecognizer(tap)
	}

	func reloadData() {
		self.trackerOptionsTableView.reloadData()
		self.emojisCollectionView.reloadData()
		self.colorsCollectionView.reloadData()
	}
}

// MARK: - Actions
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

	@objc
	func dismissKeyboard() {
		self.emptyTap?()
	}
}

private extension TrackerAddingViewController {
	func shouldHideErrorLabelWithAnimation(_ shouldHide: Bool) -> Bool {
		UIView.animate(withDuration: 0.3, animations: { [weak self] in
			self?.view.layoutIfNeeded()
		}) { [weak self] _ in
			self?.errorLabel.isHidden = shouldHide
		}

		return errorLabel.isHidden
	}
}
