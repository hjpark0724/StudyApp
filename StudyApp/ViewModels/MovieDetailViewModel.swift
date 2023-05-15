import UIKit
import Combine

class MovieDetailViewModel {
    @Published var state: MovieDetailsState = .loading
    var cancelable: AnyCancellable? = nil
    func fetchMovie(id: Int) {
        cancelable?.cancel()
        cancelable = TMDBService.shared.fetchMovie(from: id)
            .sink { [unowned self] result in
                switch result {
                case .success(let movie):
                    let movieViewModel = MovieViewModel(movie: movie, isDetails: true)
                    self.state = .success(movieViewModel)
                case .failure(let error):
                    self.state = .failure(error)
                }
            }
    }
}

enum MovieDetailsState {
    case loading
    case success(MovieViewModel)
    case failure(Error)
}
