import Foundation

struct ConvoSession: Identifiable, Hashable {
    let id = UUID()
    let mode: CuratorMode
}
