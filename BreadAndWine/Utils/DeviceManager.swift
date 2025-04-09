//
//  DeviceManager.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 09.04.25.
//


// DeviceManager.swift
import Firebase
import FirebaseFirestore
import FirebaseMessaging

class DeviceManager {
    static let shared = DeviceManager()
    
    private init() {}
    
    func saveDeviceToken(_ token: String) {
        // Get current user ID or create an anonymous ID
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        
        // Store the token in Firestore
        let db = Firestore.firestore()
        db.collection("devices").document(deviceId).setData([
            "token": token,
            "platform": "ios",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "lastActive": FieldValue.serverTimestamp()
        ], merge: true) { error in
            if let error = error {
                print("Error saving token: \(error)")
            } else {
                print("Device token saved to Firebase")
            }
        }
    }
}
