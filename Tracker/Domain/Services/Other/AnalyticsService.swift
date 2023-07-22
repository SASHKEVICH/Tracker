//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Александр Бекренев on 13.07.2023.
//

import Foundation
import YandexMobileMetrica

protocol AnalyticsServiceProtocol {
    func didOpenMainScreen()
    func didCloseMainScreen()
    func didTapAddTracker()
    func didTapTracker()
    func didTapFilter()
    func didEditTracker()
    func didDeleteTracker()
}

final class AnalyticsService {
    init() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: YandexMetricaConfiguration.Api.key) else {
            return
        }
        YMMYandexMetrica.activate(with: configuration)
    }
}

// MARK: - AnalyticsServiceProtocol

extension AnalyticsService: AnalyticsServiceProtocol {
    func didOpenMainScreen() {
        let params: [AnyHashable: Any] = ["event": "open", "screen": "Main"]
        YMMYandexMetrica.reportEvent("open_main", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        print(#function)
    }

    func didCloseMainScreen() {
        let params: [AnyHashable: Any] = ["event": "close", "screen": "Main"]
        YMMYandexMetrica.reportEvent("close_main", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        print(#function)
    }

    func didTapAddTracker() {
        let params: [AnyHashable: Any] = ["event": "click", "screen": "Main", "item": "add_track"]
        YMMYandexMetrica.reportEvent("click_add_tracker", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        print(#function)
    }

    func didTapTracker() {
        let params: [AnyHashable: Any] = ["event": "click", "screen": "Main", "item": "track"]
        YMMYandexMetrica.reportEvent("click_tracker", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        print(#function)
    }

    func didTapFilter() {
        let params: [AnyHashable: Any] = ["event": "click", "screen": "Main", "item": "filter"]
        YMMYandexMetrica.reportEvent("click_filter", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        print(#function)
    }

    func didEditTracker() {
        let params: [AnyHashable: Any] = ["event": "click", "screen": "Main", "item": "edit"]
        YMMYandexMetrica.reportEvent("click_edit", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        print(#function)
    }

    func didDeleteTracker() {
        let params: [AnyHashable: Any] = ["event": "click", "screen": "Main", "item": "delete"]
        YMMYandexMetrica.reportEvent("click_delete", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        print(#function)
    }
}
