//
//  NetworkManager.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//
import SwiftUI


class NetworkManager {
    static var shared = NetworkManager()
    
    // Configurable parameters
    private let baseURL: String
    private let timeoutInterval: TimeInterval
    private let maxRetryCount: Int
    private let retryDelay: TimeInterval
    private let cache = NSCache<NSString, NSData>()
    
    // Custom URL session configuration
    private let session: URLSession
    
    init(baseURL: String = "https://jsonplaceholder.typicode.com", // Use a test API as default
         timeoutInterval: TimeInterval = 30,
         maxRetryCount: Int = 3,
         retryDelay: TimeInterval = 2) {
        
        self.baseURL = baseURL
        self.timeoutInterval = timeoutInterval
        self.maxRetryCount = maxRetryCount
        self.retryDelay = retryDelay
        
        // Create custom URLSession configuration
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInterval
        config.timeoutIntervalForResource = timeoutInterval * 2
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
        
        print("📱 NetworkManager initialized with baseURL: \(baseURL)")
    }
    
    // Fetch with automatic retry
    func fetch<T: Codable>(_ endpoint: String,
                          method: String = "GET",
                          body: Data? = nil,
                          headers: [String: String]? = nil,
                          cacheKey: String? = nil,
                          retryCount: Int = 0,
                          useCachedDataOnError: Bool = true,
                          completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        // First check network connectivity
        guard NetworkMonitor.shared.isConnected else {
            print("📵 No internet connection available")
            
            // Try to use cached data if available
            if useCachedDataOnError, let cacheKey = cacheKey, let cachedData = cache.object(forKey: cacheKey as NSString) {
                print("💾 Using cached data for \(cacheKey) due to no internet")
                decode(cachedData as Data, completion: completion)
                return
            }
            
            completion(.failure(.noInternet))
            return
        }
        
        // Build full URL
        let urlString = endpoint.starts(with: "http") ? endpoint : "\(baseURL)/\(endpoint)"
        guard let url = URL(string: urlString) else {
            print("🔗 Invalid URL: \(urlString)")
            completion(.failure(.invalidURL))
            return
        }
        
        print("🌐 Attempting to fetch from: \(url.absoluteString) (attempt \(retryCount + 1)/\(maxRetryCount + 1))")
        
        // Create and configure the request
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = timeoutInterval
        
        // Add headers if provided
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Add body data if provided
        if let body = body {
            request.httpBody = body
        }
        
        // Check cache before making network request (only for GET requests)
        if method == "GET", let cacheKey = cacheKey, let cachedData = cache.object(forKey: cacheKey as NSString) {
            print("💾 Found cached data for \(cacheKey), checking if still fresh")
            
            // Use cached data (we'll refresh in background)
            decode(cachedData as Data) { (result: Result<T, NetworkError>) in
                switch result {
                case .success(let value):
                    completion(.success(value))
                    
                    // Continue with request in background to update cache
                    print("🔄 Refreshing cache for \(cacheKey) in background")
                    
                case .failure:
                    // If we can't decode cached data, just continue with request
                    break
                }
            }
        }
        
        // Make the network request
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Handle request completion
            if let error = error {
                // Check for timeout
                if let nsError = error as NSError?,
                   nsError.domain == NSURLErrorDomain,
                   nsError.code == NSURLErrorTimedOut {
                    print("⏰ Request timed out: \(url.absoluteString)")
                    
                    // Retry if we haven't exceeded max retries
                    if retryCount < self.maxRetryCount {
                        print("🔄 Retrying request in \(self.retryDelay) seconds...")
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.retryDelay) {
                            self.fetch(endpoint,
                                      method: method,
                                      body: body,
                                      headers: headers,
                                      cacheKey: cacheKey,
                                      retryCount: retryCount + 1,
                                      useCachedDataOnError: useCachedDataOnError,
                                      completion: completion)
                        }
                        return
                    }
                    
                    // Try using cached data as fallback
                    if useCachedDataOnError, let cacheKey = cacheKey, let cachedData = self.cache.object(forKey: cacheKey as NSString) {
                        print("💾 Using cached data for \(cacheKey) after timeout")
                        self.decode(cachedData as Data, completion: completion)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        completion(.failure(.timeout))
                    }
                    return
                }
                
                print("❌ Network Error: \(error.localizedDescription)")
                
                // Try using cached data as fallback for any error
                if useCachedDataOnError, let cacheKey = cacheKey, let cachedData = self.cache.object(forKey: cacheKey as NSString) {
                    print("💾 Using cached data for \(cacheKey) after network error")
                    self.decode(cachedData as Data, completion: completion)
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.failure(.unknown(error)))
                }
                return
            }
            
            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response Status: \(httpResponse.statusCode) for \(url.absoluteString)")
                
                // Handle status code errors
                if !(200...299).contains(httpResponse.statusCode) {
                    if httpResponse.statusCode >= 500 {
                        // Server error - retry if possible
                        if retryCount < self.maxRetryCount {
                            print("🔄 Server error, retrying in \(self.retryDelay) seconds...")
                            DispatchQueue.main.asyncAfter(deadline: .now() + self.retryDelay) {
                                self.fetch(endpoint,
                                          method: method,
                                          body: body,
                                          headers: headers,
                                          cacheKey: cacheKey,
                                          retryCount: retryCount + 1,
                                          useCachedDataOnError: useCachedDataOnError,
                                          completion: completion)
                            }
                            return
                        }
                        
                        // Try using cached data as fallback
                        if useCachedDataOnError, let cacheKey = cacheKey, let cachedData = self.cache.object(forKey: cacheKey as NSString) {
                            print("💾 Using cached data for \(cacheKey) after server error")
                            self.decode(cachedData as Data, completion: completion)
                            return
                        }
                        
                        DispatchQueue.main.async {
                            completion(.failure(.serverError))
                        }
                        return
                    } else {
                        // Client error - likely won't be fixed by retrying
                        DispatchQueue.main.async {
                            completion(.failure(.requestFailed(statusCode: httpResponse.statusCode)))
                        }
                        return
                    }
                }
            }
            
            // Check for data
            guard let data = data else {
                print("📭 No data received from server")
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            // Debug print a preview of the data
            if let dataPreview = String(data: data, encoding: .utf8)?.prefix(100) {
                print("📦 Response Data (preview): \(dataPreview)...")
            }
            
            // Cache the data if requested
            if let cacheKey = cacheKey {
                print("💾 Caching data for key: \(cacheKey)")
                self.cache.setObject(data as NSData, forKey: cacheKey as NSString)
            }
            
            // Decode the data
            self.decode(data, completion: completion)
        }
        
        task.resume()
    }
    
    // Helper method to decode data
    private func decode<T: Codable>(_ data: Data, completion: @escaping (Result<T, NetworkError>) -> Void) {
        let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase  // WordPress uses snake_case
            decoder.dateDecodingStrategy = .iso8601  // For WordPress dates
        do {
            let decodedData = try decoder.decode(T.self, from: data)
            DispatchQueue.main.async {
                completion(.success(decodedData))
            }
        } catch {
            print("🔄 Decoding error: \(error)")
            print("RAW RESPONSE: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            DispatchQueue.main.async {
                completion(.failure(.decodingError))
            }
        }
    }
    
    // Convenience methods for common API calls
    
    func fetchDevotionals(completion: @escaping (Result<[DevotionalEntry], NetworkError>) -> Void) {
        fetch("devotional", cacheKey: "recent_devotionals", completion: completion)
    }
    
    func fetchNews(completion: @escaping (Result<[NewsEntry], NetworkError>) -> Void) {
        fetch("news?count=10", cacheKey: "recent_news", completion: completion)
    }
    
    // Clear specific cache entry
    func clearCache(for key: String) {
        cache.removeObject(forKey: key as NSString)
        print("🗑️ Cleared cache for key: \(key)")
    }
    
    // Clear all cache
    func clearAllCache() {
        cache.removeAllObjects()
        print("🗑️ Cleared all cache")
    }
}
