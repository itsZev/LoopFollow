// LoopFollow
// InfoType.swift

import Foundation

enum InfoType: Int, CaseIterable {
    case iob, cob, basal, override, battery, pump, pumpBattery, sage, cage, recBolus, minMax, carbsToday, autosens, profile, target, isf, carbRatio, updated, tdd, iage

    var name: String {
        switch self {
        case .iob: return "活性胰岛素"
        case .cob: return "活性碳水"
        case .basal: return "基础率"
        case .override: return "覆盖"
        case .battery: return "电池"
        case .pump: return "泵"
        case .pumpBattery: return "泵电池"
        case .sage: return "SAGE"
        case .cage: return "CAGE"
        case .recBolus: return "建议大剂量"
        case .minMax: return "最低/最高"
        case .carbsToday: return "今日碳水"
        case .autosens: return "自动灵敏度"
        case .profile: return "配置文件"
        case .target: return "目标"
        case .isf: return "ISF"
        case .carbRatio: return "碳水比"
        case .updated: return "更新于"
        case .tdd: return "TDD"
        case .iage: return "IAGE"
        }
    }

    var defaultVisible: Bool {
        switch self {
        case .iob, .cob, .basal, .override, .battery, .pump, .sage, .cage, .recBolus, .minMax, .carbsToday:
            return true
        default:
            return false
        }
    }

    var sortOrder: Int {
        return rawValue
    }
}
