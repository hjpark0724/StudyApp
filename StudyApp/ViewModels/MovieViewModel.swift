import UIKit
import Combine

struct MovieViewModel {
    let id: Int
    let title: String
    let subtitle: String
    let overview: String
    let poster: AnyPublisher<UIImage?, Never>
    let rating: String

    init(movie: Movie, isDetails: Bool = false ) {
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview
        self.subtitle = movie.subtitle
        self.poster = isDetails ? TMDBService.shared.loadThumnail(for: movie) : TMDBService.shared.loadPoster(for: movie)
        self.rating = String(format: "%02f", movie.voteAverage)
    }
}

extension MovieViewModel: Hashable {
    static func == (lhs: MovieViewModel, rhs: MovieViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
