//
//  TrackerAddingViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import UIKit

protocol TrackerAddingViewControllerProtocol: AnyObject {
	var emptyTap: (() -> Void)? { get set }
}

final class TrackerAddingViewController: UIViewController {
	enum Flow {
		case add
		case edit
	}

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
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .Medium.big
		label.textColor = .Dynamic.blackDay
		label.text = self.viewModel.viewControllerTitle
		return label
	}()

	private let completedTimesCountLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .Bold.big
		label.textColor = .Dynamic.blackDay
		label.text = "5 дней"
		label.adjustsFontSizeToFitWidth = true
		return label
	}()

	private lazy var decreaseCompletedTimesButton: CompleteTrackerButton = {
		let button = CompleteTrackerButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.buttonState = .decrease
		button.color = .Selection.color2
		return button
	}()

	private lazy var increaseCompletedTimesButton: CompleteTrackerButton = {
		let button = CompleteTrackerButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.buttonState = .increase
		button.color = .Selection.color2
		return button
	}()
	
	private lazy var trackerTitleTextField: TrackerCustomTextField = {
		let textField = TrackerCustomTextField()
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.placeholder = R.string.localizable.trackerAddingTrackerTitleTextFieldPlaceholder()
		textField.delegate = self.titleTextFieldHelper
		textField.clearButtonMode = .whileEditing
		textField.addTarget(self, action: #selector(self.didChangeTrackerTitleTextField(_:)), for: .editingChanged)
		return textField
	}()
	
	private let errorLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.isHidden = true
		label.text = R.string.localizable.trackerAddingErrorLabelText()
		label.font = .Regular.medium
		label.textColor = .Static.red
		label.sizeToFit()
		return label
	}()
	
	private lazy var trackerOptionsTableView: UITableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.dataSource = self.optionsTableViewHelper
		tableView.delegate = self.optionsTableViewHelper
		tableView.register(
			TrackerOptionsTableViewCell.self,
			forCellReuseIdentifier: TrackerOptionsTableViewCell.reuseIdentifier
		)
		tableView.separatorColor = .Static.gray
		return tableView
	}()
	
	private lazy var emojisCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.dataSource = self.emojisHelper
		collectionView.delegate = self.emojisHelper
		collectionView.register(
			EmojisCollectionViewCell.self,
			forCellWithReuseIdentifier: EmojisCollectionViewCell.reuseIdentifier
		)
		collectionView.register(
			TrackersCollectionSectionHeader.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: TrackersCollectionSectionHeader.reuseIdentifier
		)
		return collectionView
	}()
	
	private lazy var colorsCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.dataSource = self.colorsHelper
		collectionView.delegate = self.colorsHelper
		collectionView.register(
			ColorsCollectionViewCell.self,
			forCellWithReuseIdentifier: ColorsCollectionViewCell.reuseIdentifier
		)
		collectionView.register(
			TrackersCollectionSectionHeader.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: TrackersCollectionSectionHeader.reuseIdentifier
		)
		return collectionView
	}()
	
	private lazy var cancelTrackerButton: TrackerCustomButton = {
		let title = R.string.localizable.trackerAddingCancelButtonTitle()
		let button = TrackerCustomButton(state: .cancel, title: title)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(self.didTapCancelTrackerButton), for: .touchUpInside)
		return button
	}()
	
	private lazy var addTrackerButton: TrackerCustomButton = {
		let title = R.string.localizable.trackerAddingAddTrackerButtonTitle()
		let button = TrackerCustomButton(state: .disabled, title: title)
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

	private let flow: Flow
	private let router: TrackerAddingRouterProtocol
	private let optionsTableViewHelper: TrackerOptionsTableViewHelperProtocol
	private let titleTextFieldHelper: TrackerTitleTextFieldHelperProtocol
	private let colorsHelper: ColorsCollectionViewHelperProtocol
	private let emojisHelper: EmojisCollectionViewHelperProtocol

	private var viewModel: TrackerAddingViewModelProtocol

	init(
		viewModel: TrackerAddingViewModelProtocol,
		router: TrackerAddingRouterProtocol,
		optionsTableViewHelper: TrackerOptionsTableViewHelperProtocol,
		titleTextFieldHelper: TrackerTitleTextFieldHelperProtocol,
		colorsHelper: ColorsCollectionViewHelperProtocol,
		emojisHelper: EmojisCollectionViewHelperProtocol,
		flow: Flow
	) {
		self.viewModel = viewModel
		self.router = router
		self.optionsTableViewHelper = optionsTableViewHelper
		self.titleTextFieldHelper = titleTextFieldHelper
		self.colorsHelper = colorsHelper
		self.emojisHelper = emojisHelper
		self.flow = flow
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = .Dynamic.whiteDay
		self.isModalInPresentation = true
        
		self.addSubviews()
		self.addConstraints()
		self.addGestureRecognizers()
		self.bind()

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

// MARK: - TrackerOptionsTableViewDelegate
extension TrackerAddingViewController: TrackerOptionsTableViewDelegate {
	var optionsTitles: [String] {
		self.viewModel.optionsTitles
	}

	var selectedWeekDays: [WeekDay] {
		Array(self.viewModel.selectedWeekDays)
	}

	var selectedCategory: TrackerCategory? {
		self.viewModel.selectedCategory
	}

	func didTapScheduleCell() {
		let weekDays = self.viewModel.selectedWeekDays
		self.router.navigateToScheduleScreen(selectedWeekDays: weekDays, from: self)
	}

	func didTapCategoryCell() {
		let category = self.viewModel.selectedCategory
		self.router.navigateToCategoryScreen(selectedCategory: category, from: self)
	}
}

// MARK: - TrackerEmojisCollectionViewDelegate
extension TrackerAddingViewController: TrackerEmojisCollectionViewDelegate {
	var selectedEmoji: String? {
		self.viewModel.selectedEmoji
	}

	func didSelect(emoji: String) {
		self.viewModel.didSelect(emoji: emoji)
	}
}

// MARK: - TrackerColorCollectionViewDelegate
extension TrackerAddingViewController: TrackerColorCollectionViewDelegate {
	var selectedColor: UIColor? {
		self.viewModel.selectedColor
	}

	func didSelect(color: UIColor) {
		self.viewModel.didSelect(color: color)
	}
}

// MARK: - Layout views
private extension TrackerAddingViewController {
	func addSubviews() {
		self.view.addSubview(scrollView)
		self.scrollView.addSubview(contentView)

		self.contentView.addSubview(titleLabel)
		self.contentView.addSubview(trackerTitleTextField)
		self.contentView.addSubview(errorLabel)
		self.contentView.addSubview(trackerOptionsTableView)
		self.contentView.addSubview(emojisCollectionView)
		self.contentView.addSubview(colorsCollectionView)
		self.contentView.addSubview(addTrackerButton)
		self.contentView.addSubview(cancelTrackerButton)

		if self.flow == .edit {
			self.contentView.addSubview(self.decreaseCompletedTimesButton)
			self.contentView.addSubview(self.completedTimesCountLabel)
			self.contentView.addSubview(self.increaseCompletedTimesButton)
		}
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

		if self.flow == .edit {
			NSLayoutConstraint.activate([
				decreaseCompletedTimesButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 26),
				decreaseCompletedTimesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 80),
				decreaseCompletedTimesButton.widthAnchor.constraint(equalToConstant: 34),
				decreaseCompletedTimesButton.heightAnchor.constraint(equalToConstant: 34),
			])

			NSLayoutConstraint.activate([
				completedTimesCountLabel.leadingAnchor.constraint(equalTo: decreaseCompletedTimesButton.trailingAnchor, constant: 24),
				completedTimesCountLabel.trailingAnchor.constraint(equalTo: increaseCompletedTimesButton.leadingAnchor, constant: -24)
			])

			NSLayoutConstraint.activate([
				increaseCompletedTimesButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 26),
				increaseCompletedTimesButton.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: -80),
				increaseCompletedTimesButton.widthAnchor.constraint(equalToConstant: 34),
				increaseCompletedTimesButton.heightAnchor.constraint(equalToConstant: 34),
			])
		}
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

	func bind() {
		self.viewModel.onSelectedCategoryChanged = { [weak self] in
			self?.trackerOptionsTableView.reloadData()
		}

		self.viewModel.onSelectedWeekDaysChanged = { [weak self] in
			self?.trackerOptionsTableView.reloadData()
		}
	}
}

// MARK: - Actions
private extension TrackerAddingViewController {
	@objc
	func didTapCancelTrackerButton() {
		self.router.navigateToMainScreen()
	}

	@objc
	func didTapAddTrackerButton() {
		self.viewModel.didConfirmTracker()
		self.router.navigateToMainScreen()
	}

	@objc
	func didChangeTrackerTitleTextField(_ textField: UITextField) {
//		guard let title = textField.text else { return }
//		self.presenter?.didChangeTrackerTitle(title)
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

		return self.errorLabel.isHidden
	}
}
