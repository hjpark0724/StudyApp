import Foundation
import Combine
class MoviesViewModel {
    @Published var state: MoviesSearchState = .idle
    var cancelable: Set<AnyCancellable> = []
    func fetch(query: String) {
        self.state = query.isEmpty ? .idle : .loading
        guard !query.isEmpty else {
            return
        }
        let publisher = TMDBService.shared.fetch(query: query)
        publisher.sink { [unowned self] result in
            switch result {
            case .success(let movies) where movies.items.isEmpty :
                self.state = .noResults
            case .success(let movies):
                let movieViewModel = movies.items.map { movie in
                    MovieViewModel(movie: movie)
                }
                self.state = .success(movieViewModel)
            case .failure(let error):
                self.state = .failure(error)
                print(error)
            }
        }
        .store(in: &cancelable)
    }
}

enum MoviesSearchState {
    case idle
    case loading
    case success([MovieViewModel])
    case noResults
    case failure(Error)
}
