// LoopFollow
// AlarmActiveSection.swift

import SwiftUI

struct AlarmActiveSection: View {
    @Binding var alarm: Alarm

    var body: some View {
        Section(header: Text("已启用 During")) {
            AlarmEnumMenuPicker(title: "已启用",
                                selection: $alarm.activeOption)
        }
    }
}
