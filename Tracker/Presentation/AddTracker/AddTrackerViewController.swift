//
//  AddTrackerViewController.swift
//  Tracker
//
//  Created by Александр Бекренев on 14.04.2023.
//

import UIKit

protocol TrackerScheduleViewControllerDelegate: AnyObject {
    func dismissTrackerScheduleViewController()
    func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>)
}

protocol AddTrackerViewControllerProtocol: AnyObject, TrackerScheduleViewControllerDelegate {
    var presenter: AddTrackerViewPresenterProtocol? { get set }
    var trackerScheduleViewController: TrackerScheduleViewController? { get set }
    func didTapTrackerScheduleCell(_ vc: TrackerScheduleViewController)
    func setViewControllerTitle(_ title: String)
    func showError() -> Bool
    func hideError() -> Bool
    func enableAddButton()
    func disableAddButton()
}

final class AddTrackerViewController: UIViewController, AddTrackerViewControllerProtocol {
    private let scrollView = UIScrollView()
    private let contentScrollView = UIView()
    private let titleLabel = UILabel()
    private let trackerTitleTextField = TrackerTitleTextField()
    private let errorLabel = UILabel()
    private let trackerOptionsTableView = UITableView()
    private let cancelTrackerButton = TrackerCustomButton(state: .cancel, title: "Отменить")
    private let addTrackerButton = TrackerCustomButton(state: .disabled, title: "Создать")
    
    private var tableViewTopConstraint: NSLayoutConstraint?
    
    private var titleText: String? {
        didSet {
            titleLabel.text = titleText
            titleLabel.sizeToFit()
        }
    }
    
    var presenter: AddTrackerViewPresenterProtocol?
    var trackerScheduleViewController: TrackerScheduleViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .trackerWhiteDay
        isModalInPresentation = true
        
        setupScrollView()
        setupTitleLabel()
        setupTrackerTitleTextField()
        setupErrorLabel()
        setupTableView()
        
        presenter?.viewDidLoad()
        trackerOptionsTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard contentScrollView.frame.width != 0 else { return }
        setupCancelAndAddTrackerButton()
    }
}

// MARK: - Setup and layout views
private extension AddTrackerViewController {
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
            contentScrollView.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor),
            contentScrollView.centerYAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerYAnchor),
            contentScrollView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentScrollView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
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
    
    func setupTableView() {
        contentScrollView.addSubview(trackerOptionsTableView)
        trackerOptionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableViewTopConstraint = NSLayoutConstraint(
            item: trackerOptionsTableView,
            attribute: .top,
            relatedBy: .equal,
            toItem: trackerTitleTextField,
            attribute: .bottom,
            multiplier: 1,
            constant: 24)
        
        guard let tableViewTopConstraint = tableViewTopConstraint else { return }
        
        NSLayoutConstraint.activate([
            trackerOptionsTableView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor, constant: 16),
            trackerOptionsTableView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor, constant: -16),
            tableViewTopConstraint,
            trackerOptionsTableView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        trackerOptionsTableView.dataSource = presenter?.tableViewHelper
        trackerOptionsTableView.delegate = presenter?.tableViewHelper
        trackerOptionsTableView.register(TrackerOptionsTableViewCell.self, forCellReuseIdentifier: TrackerOptionsTableViewCell.identifier)
        trackerOptionsTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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
            cancelTrackerButton.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor, constant: 20),
            cancelTrackerButton.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            
            addTrackerButton.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor, constant: -20),
            addTrackerButton.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
        ])
        
        cancelTrackerButton.addTarget(self, action: #selector(didTapCancelTrackerButton), for: .touchUpInside)
        addTrackerButton.addTarget(self, action: #selector(didTapAddTrackerButton), for: .touchUpInside)
    }
}

// MARK: - Callbacks
private extension AddTrackerViewController {
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

extension AddTrackerViewController {
    func setViewControllerTitle(_ title: String) {
        titleText = title
    }
}

// MARK: - Showing and Hiding error label
extension AddTrackerViewController {
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
extension AddTrackerViewController {
    func enableAddButton() {
        addTrackerButton.buttonState = .normal
    }
    
    func disableAddButton() {
        addTrackerButton.buttonState = .disabled
    }
}

// MARK: - Cells callbacks
extension AddTrackerViewController {
    func didTapTrackerScheduleCell(_ vc: TrackerScheduleViewController) {
        present(vc, animated: true)
    }
}

// MARK: - TrackerScheduleViewControllerDelegate
extension AddTrackerViewController: TrackerScheduleViewControllerDelegate {
    func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>) {
        presenter?.didRecieveSelectedTrackerSchedule(weekDays)
        trackerOptionsTableView.reloadData()
    }
    
    func dismissTrackerScheduleViewController() {
        dismiss(animated: true)
    }
}
