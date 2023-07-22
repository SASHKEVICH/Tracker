//
//  TrackerAddingView.swift
//  Tracker
//
//  Created by Александр Бекренев on 16.07.2023.
//

import UIKit

protocol TrackerAddingViewProtocol {
    var viewTitle: String? { get set }
    var trackerTitle: String? { get set }
    var completedTimesCount: String? { get set }
    var didTapCancel: (() -> Void)? { get set }
    var didTapConfirm: (() -> Void)? { get set }
    var didChangeTrackerTitle: ((String) -> Void)? { get set }
    var didSelectTrackerTitle: ((String) -> Void)? { get set }
    var emptyTap: (() -> Void)? { get set }
    var decreaseCompletedCount: (() -> Void)? { get set }
    var increaseCompletedCount: (() -> Void)? { get set }
    func reloadCollections()
    func reloadOptionsTable()
    func shouldHideErrorLabelWithAnimation(_ shouldHide: Bool)
    func shouldEnableConfirmButton(_ shouldEnable: Bool)
}

final class TrackerAddingView: UIView {
    enum Flow {
        case add
        case edit
    }

    var viewTitle: String? {
        didSet {
            titleLabel.text = viewTitle
            titleLabel.sizeToFit()
        }
    }

    var trackerTitle: String? {
        didSet {
            trackerTitleTextField.text = trackerTitle
        }
    }

    var completedTimesCount: String? {
        didSet {
            completedTimesCountLabel.text = completedTimesCount
        }
    }

    var didTapCancel: (() -> Void)?
    var didTapConfirm: (() -> Void)?
    var didChangeTrackerTitle: ((String) -> Void)?
    var didSelectTrackerTitle: ((String) -> Void)?
    var decreaseCompletedCount: (() -> Void)?
    var increaseCompletedCount: (() -> Void)?
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
        return label
    }()

    private lazy var completedTimesCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Bold.big
        label.textColor = .Dynamic.blackDay
        label.text = "5 дней"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var decreaseCompletedTimesButton: CompleteTrackerButton = {
        let button = CompleteTrackerButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.buttonState = .decrease
        button.color = .Selection.color2
        button.addTarget(self, action: #selector(self.didTapDecreaseCompletedCount), for: .touchUpInside)
        return button
    }()

    private lazy var increaseCompletedTimesButton: CompleteTrackerButton = {
        let button = CompleteTrackerButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.buttonState = .increase
        button.color = .Selection.color2
        button.addTarget(self, action: #selector(self.didTapIncreaseCompletedCount), for: .touchUpInside)
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

    private lazy var confirmTrackerButton: TrackerCustomButton = {
        let localizable = R.string.localizable
        let title = self.flow == .add
            ? localizable.trackerAddingAddTrackerButtonTitle()
            : localizable.trackerAddingFlowEditAddTrackerButtonTitle()
        let button = TrackerCustomButton(state: .disabled, title: title)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.didTapConfirmTrackerButton), for: .touchUpInside)
        return button
    }()

    private lazy var tableViewTopConstraint = NSLayoutConstraint(
        item: self.trackerOptionsTableView,
        attribute: .top,
        relatedBy: .equal,
        toItem: self.trackerTitleTextField,
        attribute: .bottom,
        multiplier: 1,
        constant: 24
    )

    private lazy var tableViewHeightConstraint = NSLayoutConstraint(
        item: self.trackerOptionsTableView,
        attribute: .height,
        relatedBy: .equal,
        toItem: nil,
        attribute: .height,
        multiplier: 1,
        constant: 75
    )

    private lazy var emojisCollectionViewHeightConstraint = NSLayoutConstraint(
        item: self.emojisCollectionView,
        attribute: .height,
        relatedBy: .equal,
        toItem: nil,
        attribute: .height,
        multiplier: 1,
        constant: 100
    )

    private lazy var colorsCollectionViewHeightConstraint = NSLayoutConstraint(
        item: self.colorsCollectionView,
        attribute: .height,
        relatedBy: .equal,
        toItem: nil,
        attribute: .height,
        multiplier: 1,
        constant: 100
    )

    private let optionsTableViewHelper: TrackerOptionsTableViewHelperProtocol
    private let titleTextFieldHelper: TrackerTitleTextFieldHelperProtocol
    private let colorsHelper: ColorsCollectionViewHelperProtocol
    private let emojisHelper: EmojisCollectionViewHelperProtocol
    private let flow: Flow

    init(
        optionsTableViewHelper: TrackerOptionsTableViewHelperProtocol,
        titleTextFieldHelper: TrackerTitleTextFieldHelperProtocol,
        colorsHelper: ColorsCollectionViewHelperProtocol,
        emojisHelper: EmojisCollectionViewHelperProtocol,
        flow: Flow
    ) {
        self.optionsTableViewHelper = optionsTableViewHelper
        self.titleTextFieldHelper = titleTextFieldHelper
        self.colorsHelper = colorsHelper
        self.emojisHelper = emojisHelper
        self.flow = flow

        super.init(frame: .zero)
        configure()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard contentView.frame.width != 0 else { return }
        addConstraintsToButtons()

        tableViewHeightConstraint.constant = trackerOptionsTableView.contentSize.height
        emojisCollectionViewHeightConstraint.constant = emojisCollectionView.contentSize.height
        colorsCollectionViewHeightConstraint.constant = colorsCollectionView.contentSize.height

        setNeedsLayout()
    }
}

// MARK: - TrackerAddingViewProtocol

extension TrackerAddingView: TrackerAddingViewProtocol {
    func shouldHideErrorLabelWithAnimation(_ shouldHide: Bool) {
        guard errorLabel.isHidden != shouldHide else { return }

        if shouldHide {
            tableViewTopConstraint.constant = 24
        } else {
            tableViewTopConstraint.constant = 54
        }

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?.errorLabel.isHidden = shouldHide
        }
    }

    func reloadCollections() {
        reloadData()
    }

    func reloadOptionsTable() {
        trackerOptionsTableView.reloadData()
    }

    func shouldEnableConfirmButton(_ shouldDisable: Bool) {
        confirmTrackerButton.buttonState = shouldDisable ? .disabled : .normal
    }
}

private extension TrackerAddingView {
    func configure() {
        addSubviews()
        addConstraints()
        addGestureRecognizers()
    }

    func addSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(trackerTitleTextField)
        contentView.addSubview(errorLabel)
        contentView.addSubview(trackerOptionsTableView)
        contentView.addSubview(emojisCollectionView)
        contentView.addSubview(colorsCollectionView)
        contentView.addSubview(confirmTrackerButton)
        contentView.addSubview(cancelTrackerButton)

        if flow == .edit {
            contentView.addSubview(decreaseCompletedTimesButton)
            contentView.addSubview(completedTimesCountLabel)
            contentView.addSubview(increaseCompletedTimesButton)
        }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            trackerTitleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerTitleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerTitleTextField.heightAnchor.constraint(equalToConstant: 75),
        ])

        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: trackerTitleTextField.bottomAnchor, constant: 8),
            errorLabel.heightAnchor.constraint(equalToConstant: 22),
            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            trackerOptionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerOptionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableViewTopConstraint,
            tableViewHeightConstraint,
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
            colorsCollectionViewHeightConstraint,
        ])

        if flow == .edit {
            NSLayoutConstraint.activate([
                decreaseCompletedTimesButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 26),
                decreaseCompletedTimesButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 80),
                decreaseCompletedTimesButton.widthAnchor.constraint(equalToConstant: 34),
                decreaseCompletedTimesButton.heightAnchor.constraint(equalToConstant: 34),
            ])

            NSLayoutConstraint.activate([
                completedTimesCountLabel.leadingAnchor.constraint(equalTo: decreaseCompletedTimesButton.trailingAnchor, constant: 24),
                completedTimesCountLabel.trailingAnchor.constraint(equalTo: increaseCompletedTimesButton.leadingAnchor, constant: -24),
                completedTimesCountLabel.centerYAnchor.constraint(equalTo: decreaseCompletedTimesButton.centerYAnchor),
            ])

            NSLayoutConstraint.activate([
                increaseCompletedTimesButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 26),
                increaseCompletedTimesButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -80),
                increaseCompletedTimesButton.widthAnchor.constraint(equalToConstant: 34),
                increaseCompletedTimesButton.heightAnchor.constraint(equalToConstant: 34),
            ])

            NSLayoutConstraint.activate([
                trackerTitleTextField.topAnchor.constraint(equalTo: decreaseCompletedTimesButton.bottomAnchor, constant: 40),
            ])
        } else {
            NSLayoutConstraint.activate([
                trackerTitleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            ])
        }
    }

    func addConstraintsToButtons() {
        let cellWidth = (contentView.bounds.width - 20 * 2 - 8) / 2

        [confirmTrackerButton, cancelTrackerButton].forEach {
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 60),
                $0.widthAnchor.constraint(equalToConstant: cellWidth),
            ])
        }

        NSLayoutConstraint.activate([
            cancelTrackerButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            cancelTrackerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelTrackerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            confirmTrackerButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            confirmTrackerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            confirmTrackerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
    }

    func reloadData() {
        trackerOptionsTableView.reloadData()
        emojisCollectionView.reloadData()
        colorsCollectionView.reloadData()
    }
}

// MARK: - Actions

private extension TrackerAddingView {
    @objc
    func didTapCancelTrackerButton() {
        didTapCancel?()
    }

    @objc
    func didTapConfirmTrackerButton() {
        didTapConfirm?()
    }

    @objc
    func didChangeTrackerTitleTextField(_ textField: UITextField) {
        guard let title = textField.text else { return }
        didChangeTrackerTitle?(title)
    }

    @objc
    func dismissKeyboard() {
        emptyTap?()
        guard let title = trackerTitleTextField.text else { return }
        didSelectTrackerTitle?(title)
    }

    @objc
    func didTapIncreaseCompletedCount() {
        increaseCompletedCount?()
    }

    @objc
    func didTapDecreaseCompletedCount() {
        decreaseCompletedCount?()
    }
}
