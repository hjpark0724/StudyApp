import Foundation
import Combine
import UIKit
struct TMDBService {
    static let shared = TMDBService()
    let apiKey = "181af7fcab50e40fabe2d10cc8b90e37"
    let baseUrl = "https://api.themoviedb.org/3"
    let postUrl =  "https://image.tmdb.org/t/p/original"
    let thumbnailUrl = "https://image.tmdb.org/t/p/w154"
    
    private init() { }
    
    func fetch(query: String) -> AnyPublisher<Result<Movies, Error>, Never> {
        let url = baseUrl + "/search/movie"
        let parameters: [String: CustomStringConvertible] = [
            "api_key": apiKey,
            "query": query,
            "language": Locale.preferredLanguages[0]
        ]
        let resource = Resource<Movies>(url: url, parameters: parameters)
        return NetworkService.load(resource: resource)
            .map { .success($0) }
            .catch { error -> AnyPublisher<Result<Movies, Error>, Never> in .just(.failure(error)) }
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func fetchMovie(from id: Int) -> AnyPublisher<Result<Movie, Error>, Never> {
        let url = baseUrl + "/movie/\(id)"
        let parameters: [String : CustomStringConvertible] = [
            "api_key": apiKey,
            "language": Locale.preferredLanguages[0]
            ]
        let resource = Resource<Movie>(url: url, parameters: parameters)
        return NetworkService.load(resource: resource)
            .map { .success($0) }
            .catch { error -> AnyPublisher<Result<Movie, Error>, Never> in .just(.failure(error)) }
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func loadThumnail(for movie: Movie) -> AnyPublisher<UIImage?, Never> {
        return Deferred{ Just(movie.poster) }
            .flatMap { poster -> AnyPublisher<UIImage?, Never> in
            guard let poster = poster else { return .just(nil) }
            let urlString = thumbnailUrl + "/\(poster)"
            guard let url = URL(string: urlString) else { return .just(nil) }
                return TMDBService.loadImage(url: url)
        }
        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
        
    }
    
    func loadPoster(for movie: Movie) -> AnyPublisher<UIImage?, Never> {
        return Deferred{ Just(movie.poster) }
            .flatMap { poster -> AnyPublisher<UIImage?, Never> in
            guard let poster = poster else { return .just(nil) }
            let urlString = postUrl + "/\(poster)"
            guard let url = URL(string: urlString) else { return .just(nil) }
                return TMDBService.loadImage(url: url)
        }
        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    private static func loadImage(url: URL) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map{(data, response) -> UIImage? in
                return UIImage(data: data)
            }
            .catch{ error in Just(nil) }
            .eraseToAnyPublisher()
    }
}
