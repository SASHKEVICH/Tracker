//
//  TrackerNewCategoryViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 07.07.2023.
//

import UIKit

protocol TrackerNewCategoryViewControllerDelegate: AnyObject {
    func dismissNewCategoryViewController()
}

final class TrackerNewCategoryViewController: UIViewController {
    weak var delegate: TrackerNewCategoryViewControllerDelegate?
    var emptyTap: (() -> Void)?

    private var viewModel: TrackerNewCategoryViewModelProtocol

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = R.string.localizable.trackerNewCategoryViewControllerTitle()
        label.font = .Medium.big
        label.textColor = .Dynamic.blackDay
        label.sizeToFit()
        return label
    }()

    private lazy var newCategoryTitleTextField: TrackerCustomTextField = {
        let textField = TrackerCustomTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = R.string.localizable.trackerNewCategoryNewCategoryTitleTextFieldPlaceholder()
        textField.delegate = self
        return textField
    }()

    private lazy var addNewCategoryButton: TrackerCustomButton = {
        let title = R.string.localizable.trackerNewCategoryAddNewCategoryButtonTitle()
        let button = TrackerCustomButton(state: .disabled, title: title)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.didTapAddNewCategoryButton), for: .touchUpInside)
        return button
    }()

    init(viewModel: TrackerNewCategoryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .Dynamic.whiteDay

        self.addSubviews()
        self.addConstraints()
        self.addGestureRecognizers()
        self.bind()
    }
}

// MARK: - UITextFieldDelegate

extension TrackerNewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        self.dismissKeyboard()
        return true
    }
}

private extension TrackerNewCategoryViewController {
    func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(newCategoryTitleTextField)
        view.addSubview(addNewCategoryButton)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            newCategoryTitleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            newCategoryTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newCategoryTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            newCategoryTitleTextField.heightAnchor.constraint(equalToConstant: 75)
        ])

        NSLayoutConstraint.activate([
            addNewCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addNewCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addNewCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addNewCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    func bind() {
        self.viewModel.onIsAddNewCategoryButtonDisabledChanged = { [weak self] in
            guard let self = self else { return }
            self.addNewCategoryButton.buttonState = self.viewModel.isAddNewCategoryButtonDisabled ? .disabled : .normal
        }
    }

    func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
}

// MARK: - Actions

private extension TrackerNewCategoryViewController {
    @objc
    func didTapAddNewCategoryButton() {
        guard let title = self.newCategoryTitleTextField.text else { return }
        viewModel.save(categoryTitle: title)
        delegate?.dismissNewCategoryViewController()
    }

    @objc
    func dismissKeyboard() {
        self.emptyTap?()

        guard let title = self.newCategoryTitleTextField.text else { return }
        viewModel.didRecieve(categoryTitle: title)
    }
}
