// LoopFollow
// OnboardingViewModel.swift

import Combine
import SwiftUI

/// Drives the onboarding wizard: tracks the current step, the chosen data
/// source, the seeded alarms, and persists everything when the user finishes.
///
/// The child connection view models are the same ones used by the regular
/// settings screens, so URL/token/credential entry and validation behave
/// identically here and there.
@MainActor
final class OnboardingViewModel: ObservableObject {
    enum DataSource: Hashable {
        case nightscout
        case dexcom
    }

    /// A single default alarm offered on the alarms step.
    struct SeedAlarm: Identifiable {
        let id = UUID()
        var alarm: Alarm
        var isEnabled: Bool = true

        var type: AlarmType { alarm.type }
    }

    @Published var step: OnboardingStep = .welcome
    @Published var dataSource: DataSource?
    @Published var seedAlarms: [SeedAlarm]

    let nightscoutViewModel = NightscoutSettingsViewModel()
    let dexcomViewModel = DexcomSettingsViewModel()

    /// Called to dismiss the onboarding cover.
    private let onClose: () -> Void
    private var cancellables = Set<AnyCancellable>()

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        seedAlarms = [.low, .high, .missedReading, .notLooping, .battery]
            .map { SeedAlarm(alarm: Alarm(type: $0)) }

        // Re-publish child changes so the footer's `canProceed` stays in sync
        // with live connection validation.
        nightscoutViewModel.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)
        dexcomViewModel.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Derived state

    /// True when the user already has a working data source — used to make
    /// skipping prominent for returning users.
    var isAlreadyConfigured: Bool {
        let nightscout = !Storage.shared.url.value.isEmpty
        let dexcom = !Storage.shared.shareUserName.value.isEmpty
            && !Storage.shared.sharePassword.value.isEmpty
        return nightscout || dexcom
    }

    var canProceed: Bool {
        switch step {
        case .welcome, .units, .alarms, .completion:
            return true
        case .dataSource:
            return dataSource != nil
        case .connect:
            switch dataSource {
            case .nightscout: return nightscoutViewModel.isConnected
            case .dexcom: return dexcomViewModel.hasCredentials
            case .none: return false
            }
        }
    }

    /// Whether a seeded alarm should be offered. Device/system alarms (Not
    /// Looping, Low Battery, …) rely on loop and uploader data that only a
    /// Nightscout site provides, so they're hidden for a Dexcom-only follower who
    /// has no such data. Other groups are always offered.
    func isSeedAlarmOffered(_ type: AlarmType) -> Bool {
        guard type.group == .device else { return true }
        return dataSource == .nightscout || !Storage.shared.url.value.isEmpty
    }

    /// Progress fraction (0...1) across the chrome'd steps, for the progress bar.
    var progress: Double {
        let total = Double(OnboardingStep.allCases.count - 1)
        guard total > 0 else { return 0 }
        return Double(step.rawValue) / total
    }

    // MARK: - Navigation

    func advance() {
        guard let next = step.next else {
            finish()
            return
        }
        step = next
    }

    func goBack() {
        guard let previous = step.previous else { return }
        step = previous
    }

    /// Skip the rest of setup. Marks onboarding complete without seeding alarms
    /// or touching units, leaving any existing configuration untouched.
    func skip() {
        Storage.shared.hasCompletedOnboarding.value = true
        onClose()
    }

    /// Finish setup: seed selected alarms, mark units/onboarding complete, and
    /// kick a refresh so the home screen loads data immediately.
    func finish() {
        persistSeededAlarms()
        Storage.shared.hasConfiguredUnits.value = true
        Storage.shared.hasCompletedOnboarding.value = true
        onClose()
        NotificationCenter.default.post(name: NSNotification.Name("refresh"), object: nil)
    }

    // MARK: - Alarm seeding

    private func persistSeededAlarms() {
        var alarms = Storage.shared.alarms.value
        let existingTypes = Set(alarms.map(\.type))

        for seed in seedAlarms where seed.isEnabled && isSeedAlarmOffered(seed.type) {
            guard !existingTypes.contains(seed.type) else { continue }
            alarms.append(seed.alarm)
        }

        Storage.shared.alarms.value = alarms
    }
}
