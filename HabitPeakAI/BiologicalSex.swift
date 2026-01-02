import Foundation

enum BiologicalSex: String, CaseIterable, Codable, Identifiable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue
    }
}
