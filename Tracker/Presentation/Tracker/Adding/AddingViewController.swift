import UIKit

protocol AddingViewControllerProtocol: AnyObject {
    var emptyTap: (() -> Void)? { get set }
}

final class AddingViewController: UIViewController, AddingViewControllerProtocol {
    var emptyTap: (() -> Void)?

    private let router: AddingRouterProtocol
    private var addingView: AddingViewProtocol
    private var viewModel: AddingViewModelProtocol

    init(
        router: AddingRouterProtocol,
        view: AddingViewProtocol,
        viewModel: AddingViewModelProtocol
    ) {
        self.viewModel = viewModel
        self.router = router
        self.addingView = view
        super.init(nibName: nil, bundle: nil)

        self.configureView()
        self.bind()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        guard let view = self.addingView as? UIView else { return }
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addingView.shouldEnableConfirmButton(self.viewModel.isConfirmButtonDisabled)
    }
}

// MARK: - CategoryViewControllerDelegate

extension AddingViewController: CategoryViewControllerDelegate {
    func didRecieveCategory(_ category: TrackerCategory) {
        self.viewModel.didSelect(category: category)
    }
}

// MARK: - TrackerScheduleViewControllerDelegate

extension AddingViewController: TrackerScheduleViewControllerDelegate {
    func didRecieveSelectedWeekDays(_ weekDays: Set<WeekDay>) {
        self.viewModel.didSelect(weekDays: weekDays)
        self.dismiss(animated: true)
    }
}

// MARK: - OptionsTableViewDelegate

extension AddingViewController: OptionsTableViewDelegate {
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

// MARK: - EmojisCollectionViewDelegate

extension AddingViewController: EmojisCollectionViewDelegate {
    var selectedEmoji: String? {
        self.viewModel.selectedEmoji
    }

    func didSelect(emoji: String) {
        self.viewModel.didSelect(emoji: emoji)
    }
}

// MARK: - TrackerColorCollectionViewDelegate

extension AddingViewController: ColorCollectionViewDelegate {
    var selectedColor: UIColor? {
        self.viewModel.selectedColor
    }

    func didSelect(color: UIColor) {
        self.viewModel.didSelect(color: color)
    }
}

private extension AddingViewController {
    func configureView() {
        self.view.backgroundColor = .Dynamic.whiteDay
        self.isModalInPresentation = true

        self.addingView.viewTitle = self.viewModel.viewControllerTitle
        self.addingView.trackerTitle = self.viewModel.trackerTitle

        self.addingView.didTapCancel = { [weak self] in
            self?.router.navigateToMainScreen()
        }

        self.addingView.didTapConfirm = { [weak self] in
            guard let self = self else { return }
            self.router.navigateToMainScreen()
            self.viewModel.didConfirmTracker()
        }

        self.addingView.didChangeTrackerTitle = { [weak self] title in
            guard let self = self else { return }
            self.viewModel.didChangeTracker(title: title)
        }

        self.addingView.didSelectTrackerTitle = { [weak self] title in
            guard let self = self else { return }
            self.viewModel.didSelect(title: title)
        }

        guard let viewModel = self.viewModel as? TrackerEditingViewModelProtocol else { return }
        self.addingView.completedTimesCount = viewModel.completedCount

        self.addingView.increaseCompletedCount = { [weak viewModel] in
            viewModel?.increaseCompletedCount()
        }

        self.addingView.decreaseCompletedCount = { [weak viewModel] in
            viewModel?.decreaseCompletedCount()
        }
    }

    func bind() {
        self.viewModel.onSelectedCategoryChanged = { [weak self] in
            self?.addingView.reloadOptionsTable()
        }

        self.viewModel.onSelectedWeekDaysChanged = { [weak self] in
            self?.addingView.reloadOptionsTable()
        }

        self.viewModel.onIsConfirmButtonDisabledChanged = { [weak self] in
            guard let self = self else { return }
            self.addingView.shouldEnableConfirmButton(self.viewModel.isConfirmButtonDisabled)
        }

        self.viewModel.onIsErrorHiddenChanged = { [weak self] in
            guard let self = self else { return }
            self.addingView.shouldHideErrorLabelWithAnimation(self.viewModel.isErrorHidden)
        }

        guard let viewModel = self.viewModel as? TrackerEditingViewModelProtocol else { return }
        viewModel.onCompletedCountChanged = { [weak self, weak viewModel] in
            self?.addingView.completedTimesCount = viewModel?.completedCount
        }
    }
}
