// LoopFollow
// OnboardingStep.swift

import Foundation

/// The ordered steps of the first-run onboarding wizard.
///
/// `connect` renders either the Nightscout or Dexcom screen depending on the
/// data source the user picks in `dataSource`, so the ordering stays linear and
/// the progress indicator has a stable length.
enum OnboardingStep: Int, CaseIterable {
    case welcome
    case dataSource
    case connect
    case units
    case alarms
    case completion

    var next: OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }

    var previous: OnboardingStep? {
        OnboardingStep(rawValue: rawValue - 1)
    }

    /// Steps that show the progress bar and the Back/Next footer. The welcome and
    /// completion screens are full-bleed and provide their own call-to-action.
    var showsChrome: Bool {
        switch self {
        case .welcome, .completion:
            return false
        case .dataSource, .connect, .units, .alarms:
            return true
        }
    }
}
