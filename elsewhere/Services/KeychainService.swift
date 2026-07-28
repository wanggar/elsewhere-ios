import Foundation
import Security

/// Simple Keychain wrapper for storing string values.
enum KeychainService {
    private static let service = "com.elsewhere.auth"

    enum Key: String {
        case accessToken  = "accessToken"
        case refreshToken = "refreshToken"
        case userId       = "userId"
        case displayName  = "displayName"
    }

    static func set(_ value: String, for key: Key) {
        let data = Data(value.utf8)
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue,
        ]
        SecItemDelete(query as CFDictionary)
        let attrs: [CFString: Any] = query.merging([
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]) { $1 }
        SecItemAdd(attrs as CFDictionary, nil)
    }

    static func get(_ key: Key) -> String? {
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrService:      service,
            kSecAttrAccount:      key.rawValue,
            kSecReturnData:       true,
            kSecMatchLimit:       kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(_ key: Key) {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue,
        ]
        SecItemDelete(query as CFDictionary)
    }

    static func clearAll() {
        for key in Key.allCases { delete(key) }
    }
}

extension KeychainService.Key: CaseIterable {}
