//
//  FlickrAPI.swift
//  Photorama
//
//  Created by Pierce Gallego on 11/24/23.
//

import Foundation

enum EndPoint: String {
    case interestingPhotos = "flickr.interestingness.getList"
    case recentPhotos = "flickr.photos.getRecent"
}

struct FlickrAPI {
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "4a75990a7bd3da9b38c8a08f1b451f11"
    
    
    static var interestingPhotosURL: URL {
        return flickrURL(endpoint: .interestingPhotos, parameters: ["extras":"url_z,date_taken"])
    }
    
    static var recentPhotosURL: URL {
        return flickrURL(endpoint: .recentPhotos, parameters: ["extras":"url_z,date_taken"])
    }
    
    private static func flickrURL(endpoint: EndPoint, parameters: [String:String]?) -> URL {
        var components = URLComponents(string: baseURLString)!
        var queryItems = [URLQueryItem]()
        let baseParams = [
            "method": endpoint.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": apiKey
        ]
        
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        
        components.queryItems = queryItems
        return components.url!
    }
    //decoding JSON data
    static func photos(fromJSON data: Data) -> Result<[FlickrPhoto], Error> {
        do {
            let decoder = JSONDecoder()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let flickrResponse = try decoder.decode(FlickrResponse.self, from: data)
            let photos = flickrResponse.photosInfo.photos.filter { $0.remoteURL != nil }
            return .success(photos)
        } catch {
            return .failure(error)
        }
    }
}
