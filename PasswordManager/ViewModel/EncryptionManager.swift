
//  EncryptionManager.swift
//  PasswordManager
//
//  Created by chetu on 04/04/25.


import Security
import CryptoKit
import Foundation

class EncryptionManager {
    
    private static var encryptionKey: SymmetricKey? = loadEncryptionKeyFromKeychain()

    static func encrypt(password: String) -> String? {
        if encryptionKey == nil {
            encryptionKey = SymmetricKey(size: .bits256)
            saveEncryptionKeyToKeychain()
        }

        guard let encryptionKey = encryptionKey else {
            print("Encryption key is missing.")
            return nil
        }
        
        guard let data = password.data(using: .utf8) else { return nil }
        
        let nonce = AES.GCM.Nonce()

        do {
            let sealedBox = try AES.GCM.seal(data, using: encryptionKey, nonce: nonce)

            var combinedData = nonce.withUnsafeBytes { Data($0) }
            combinedData.append(sealedBox.ciphertext)
            combinedData.append(sealedBox.tag)
            
            return combinedData.base64EncodedString()
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }

    static func decrypt(encryptedPassword: String) -> String? {
        guard let encryptionKey = encryptionKey else {
            print("Encryption key is missing.")
            return nil
        }
        
        guard let data = Data(base64Encoded: encryptedPassword) else {
            print("Error: Encrypted data is not valid Base64.")
            return nil
        }

        guard data.count >= 12 + 16 else {
            print("Error: Encrypted data is too short to be valid.")
            return nil
        }

        let nonce = data.prefix(12)
        let ciphertext = data[12..<(data.count - 16)]
        let tag = data.suffix(16)

        do {
            let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonce), ciphertext: ciphertext, tag: tag)

            let decryptedData = try AES.GCM.open(sealedBox, using: encryptionKey)
            
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption error: \(error.localizedDescription)")
            return nil
        }
    }

    private static func saveEncryptionKeyToKeychain() {
        guard let encryptionKey = encryptionKey else { return }
        
        let keyData = encryptionKey.withUnsafeBytes { Data($0) }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "encryptionKey",
            kSecValueData as String: keyData
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private static func loadEncryptionKeyFromKeychain() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "encryptionKey",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        
        return SymmetricKey(data: data)
    }
}




