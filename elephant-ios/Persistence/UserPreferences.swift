import Foundation

enum UserPreferences {
    private static let hasLaunchedKey = "hasLaunchedBefore"
    private static let hasCompletedTutorialKey = "hasCompletedTutorial"
    private static let turnTimerEnabledKey = "turnTimerEnabled"

    static var isFirstLaunch: Bool {
        !UserDefaults.standard.bool(forKey: hasLaunchedKey)
    }

    static func markLaunched() {
        UserDefaults.standard.set(true, forKey: hasLaunchedKey)
    }

    static var hasCompletedTutorial: Bool {
        get { UserDefaults.standard.bool(forKey: hasCompletedTutorialKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasCompletedTutorialKey) }
    }

    static var turnTimerEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: turnTimerEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: turnTimerEnabledKey) }
    }
}
