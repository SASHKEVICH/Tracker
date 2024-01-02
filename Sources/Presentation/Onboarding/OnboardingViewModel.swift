import Foundation

protocol OnboardingViewModelProtocol {
    var currentPageIndex: Box<Int> { get }

    func didTapOnboardingButton()
}

protocol OnboardingViewModelDelegateProtocol {
    func setCurrentPage(index: Int)
}

final class OnboardingViewModel {
    var currentPageIndex = Box<Int>(0)

    private let finishCompletion: () -> Void

    init(finishCompletion: @escaping () -> Void) {
        self.finishCompletion = finishCompletion
    }
}

// MARK: - OnboardingViewModelProtocol

extension OnboardingViewModel: OnboardingViewModelProtocol {
    func didTapOnboardingButton() {
        self.finishCompletion()
    }
}

// MARK: - OnboardingViewModelDelegateProtocol

extension OnboardingViewModel: OnboardingViewModelDelegateProtocol {
    func setCurrentPage(index: Int) {
        self.currentPageIndex.value = index
    }
}
