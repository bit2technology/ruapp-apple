//
//  URLRequest+Custom.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

public extension URLRequest {
    func response(completion: @escaping CompletionHandler<Data>) {
        URLSession.shared.dataTask(with: self) { (data, response, error) in
            #if DEBUG
                print("Response url:\(response?.url?.absoluteString ?? "") data:\(data?.string ?? "") error:\(error?.localizedDescription ?? "")")
            #endif
            if let error = error {
                completion {
                    throw error
                }
            } else if let data = data {
                completion {
                    return data
                }
            } else {
                completion {
                    throw URLRequestError.unknown
                }
            }
        }.resume()
    }
}

public enum URLRequestError: Error {
    case unknown
}
