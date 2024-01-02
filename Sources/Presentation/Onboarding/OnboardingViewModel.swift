import Foundation

protocol OnboardingViewModelProtocol {
    func didTapOnboardingButton()
}

final class OnboardingViewModel: OnboardingViewModelProtocol {
    private let finishCompletion: () -> Void

    init(finishCompletion: @escaping () -> Void) {
        self.finishCompletion = finishCompletion
    }

    func didTapOnboardingButton() {
        self.finishCompletion()
    }
}
