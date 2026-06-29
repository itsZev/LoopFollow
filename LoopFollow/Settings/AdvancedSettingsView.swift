// LoopFollow
// AdvancedSettingsView.swift

import SwiftUI

struct AdvancedSettingsView: View {
    @ObservedObject var viewModel: AdvancedSettingsViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("高级设置")) {
                    Toggle("Download 治疗事件", isOn: $viewModel.downloadTreatments)
                    Toggle("Download 预测", isOn: $viewModel.downloadPrediction)
                    Toggle("图表显示基础率", isOn: $viewModel.graphBasal)
                    Toggle("图表显示大剂量", isOn: $viewModel.graphBolus)
                    Toggle("图表显示碳水", isOn: $viewModel.graphCarbs)
                    Toggle("Graph Other 治疗事件", isOn: $viewModel.graphOtherTreatments)

                    Stepper(value: $viewModel.bgUpdateDelay, in: 1 ... 30, step: 1) {
                        Text("血糖更新延迟(秒):\(viewModel.bgUpdateDelay)")
                    }
                }

                Section(header: Text("日志选项")) {
                    Toggle("调试日志级别", isOn: $viewModel.debugLogLevel)
                }
            }
        }
        .preferredColorScheme(Storage.shared.appearanceMode.value.colorScheme)
        .navigationBarTitle("高级设置", displayMode: .inline)
    }
}
