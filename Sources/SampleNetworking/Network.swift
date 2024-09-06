//
//  Network.swift
//  SPM
//
//  Created by Raghu on 06/09/24.
//

import Foundation

public enum HTTPMethod : String{
    case get = "GET"
    case post = "POST"
    var apiValue : String {
        return rawValue
    }
}
public enum networkErrors: Error{
    
    case noUrl
    case noResponce
    case noData
    case decodingError
    case unexpectedError
}
public protocol ApiProtocol{
    
    func getList<T:Codable>(url:String , httpMethod: HTTPMethod , expecting: T.Type , completion: @escaping(Result<T , networkErrors>) -> Void)
    
}
public class HTTPClient : ApiProtocol{
    public init() {
         
    }
    
    public func getList<T:Codable>(url: String, httpMethod: HTTPMethod, expecting: T.Type, completion: @escaping (Result<T, networkErrors>) -> Void){

        guard let url = URL(string: url) else{
            return completion(.failure(.noUrl))
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue

        URLSession.shared.dataTask(with: request) { data , responce , error in
            
            guard let responce = responce as? HTTPURLResponse else{
                return completion(.failure(.noResponce))
            }
            guard let data = data , error == nil else{
                return completion(.failure(.noData))
            }
            if responce.statusCode == 200 {
                do {
                    let finalData = try JSONDecoder().decode(T .self, from: data)
                    completion(.success(finalData))
                }catch{
                    completion(.failure(.unexpectedError))
                }
            }
        }.resume()
    }
}

