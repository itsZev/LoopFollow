// LoopFollow
// DeleteAlarmSection.swift

//
//  DeleteAlarmSection.swift
//  LoopFollow
//
//  Created by Jonas Björkert on 2025-06-09.
//  Copyright © 2025 Jon Fawcett. All rights reserved.
//
import SwiftUI

struct DeleteAlarmSection: View {
    @State private var ask = false
    let delete: () -> Void

    var body: some View {
        Section {
            Button(role: .destructive) {
                ask = true
            } label: {
                Label("删除报警", systemImage: "trash")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .alert("确定删除此报警？", isPresented: $ask) {
            Button("删除", role: .destructive, action: delete)
            Button("取消", role: .cancel) {}
        }
    }
}
