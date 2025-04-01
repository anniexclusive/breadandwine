//
//  NetworkError.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//

import Foundation
import Network

enum NetworkError: Error {
    case invalidURL
    case requestFailed(statusCode: Int)
    case noData
    case decodingError
    case noInternet
    case timeout
    case serverError
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        case .noData:
            return "No data received from server"
        case .decodingError:
            return "Failed to decode server response"
        case .noInternet:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .serverError:
            return "Server error occurred"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
