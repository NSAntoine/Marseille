//
//  Network.swift
//  Marseille
//
//  Created by Serena on 03/01/2023
//

import Foundation

/// A utility class to help with networking functions
class Network  {
    
    typealias FetchingStatusCompletionHandler = (FetchingStatus) -> Void
    static let shared = Network()
    
    private init() {}
    
    /// The range of status codes that are okay when returned,
    /// any status code returned that is not in this range is treated as an error
    private let goodStatusCodesRange = 200...299
    
	/// The cache for topic documentations
	let networkCache = NSCache<NSURL, StructWrapper<TopicDocumentation>>()
	
    /// Send a request to a specified URL and decode the response as JSON using an (optionally) provided decoder
    func request<T: Decodable>(to url: URL, decoder: JSONDecoder = JSONDecoder(), returning type: T.Type,
                               handler: FetchingStatusCompletionHandler? = nil) async throws -> T {
        /*
        if #unavailable(iOS 15) {
            return try await withCheckedThrowingContinuation { continuation in
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error {
                        return continuation.resume(throwing: error)
                    }
                    
                    guard let data else {
                        return continuation.resume(throwing: Errors.invalidDataReturned(server: url))
                    }
                    
                    let result = Result {
                        try decoder.decode(type, from: data)
                    }
                    
                    continuation.resume(with: result)
                }
                .resume()
            }
        }
         */
        
        handler?(.networkFetching)
        let data: Data = try await request(to: url)
        handler?(.decoding)
        return try decoder.decode(type, from: data)
    }
    
    @discardableResult
    func request(to url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        // Make sure that status code we got is good
        if let response = response as? HTTPURLResponse, !goodStatusCodesRange.contains(response.statusCode) {
            throw Errors.badServerResponse(server: url, response: response)
        }
        
        return data
    }
	
    enum FetchingStatus {
        case networkFetching
        case decoding
    }
    
	/// Retrieve the topic documentation, either out of cache (if it exists), or request it.
    func topicDocumentation(for url: URL, allowCache: Bool = true, statusUpdater: ((FetchingStatus) -> Void)? = nil) async throws -> TopicDocumentation {
		if allowCache, let cached = networkCache.object(forKey: url as NSURL) {
			print("here")
			return cached.value
		}
		
		let docs = try await request(to: url, returning: TopicDocumentation.self, handler: statusUpdater)
		networkCache.setObject(StructWrapper(value: docs), forKey: url as NSURL)
		return docs
	}
	
    enum Errors: Swift.Error, LocalizedError, CustomStringConvertible {
        case badServerResponse(server: URL, response: HTTPURLResponse)
        case invalidDataReturned(server: URL)
        
        var errorDescription: String? {
            description
        }
        
        var description: String {
            switch self {
            case .badServerResponse(let server, let response):
                return "Server \(server) returned bad status code. (Supposed to be between 200 to 299, got \(response.statusCode))"
            case .invalidDataReturned(let server):
                return "Server \(server) returned invalid data"
            }
        }
    }
}
