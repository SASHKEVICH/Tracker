import UIKit

final class StatisticsViewController: UIViewController {
    private lazy var statisticsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            StatisticsTableViewCell.self,
            forCellReuseIdentifier: StatisticsTableViewCell.reuseIdentifier
        )
        tableView.dataSource = self.tableViewHelper
        tableView.delegate = self.tableViewHelper
        tableView.backgroundColor = .Dynamic.whiteDay
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 77, left: 0, bottom: 0, right: 0)
        return tableView
    }()

    private lazy var placeholderView: TrackerPlaceholderView = {
        let view = TrackerPlaceholderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.set(state: .emptyStatistics)
        return view
    }()

    private var viewModel: StatisticsViewModelProtocol
    private let tableViewHelper: StatisticsTableViewHelperProtocol

    init(viewModel: StatisticsViewModelProtocol, tableViewHelper: StatisticsTableViewHelperProtocol) {
        self.viewModel = viewModel
        self.tableViewHelper = tableViewHelper
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .Dynamic.whiteDay
        self.setupNavigationItem()
        self.addSubviews()
        self.addConstraints()
        self.bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.statisticsTableView.reloadData()
        self.viewModel.fetchCompletedTrackers()
    }
}

// MARK: - StatisticsTableViewHelperDelegate

extension StatisticsViewController: StatisticsTableViewHelperDelegate {
    var statistics: [Statistics] {
        Array(self.viewModel.statistics.value)
    }
}

private extension StatisticsViewController {
    func setupNavigationItem() {
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.title = R.string.localizable.statisticsNavigationItemTitle()
        self.definesPresentationContext = true
    }

    func addSubviews() {
        self.view.addSubview(self.statisticsTableView)
        self.view.insertSubview(self.placeholderView, aboveSubview: self.statisticsTableView)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            self.placeholderView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.placeholderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.placeholderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.placeholderView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.statisticsTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.statisticsTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.statisticsTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.statisticsTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func bind() {
        self.viewModel.statistics.bind { [weak self] _ in
            self?.statisticsTableView.reloadData()
        }

        self.viewModel.isPlaceholderHidden.bind { [weak self] isHidden in
            guard let self = self else { return }
            self.placeholderView.isHidden = isHidden
        }
    }
}
