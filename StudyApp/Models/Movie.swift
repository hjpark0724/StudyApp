import Foundation

struct Movies : Decodable {
    let items: [Movie]
    enum CodingKeys: String, CodingKey {
        case items = "results"
    }
}


struct Movie: Decodable {
    let id: Int
    let title: String
    let overview: String
    let poster: String?
    let voteAverage: Float
    let releaseDate: String?
    let genreIds: [GenreId]?
    let genres: [Genre]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case poster = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case genres = "genres"
    }
}

extension Movie: Hashable {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Movie {
    var genreNames: [String] {
        if let genreIds = genreIds {
            return genreIds.map { $0.description }
        }
        if let genres = genres {
            return genres.map { $0.name }
        }
        return []
    }
    var subtitle: String {
        let genresDescription = genreNames.joined(separator: ", ")
        return "\(releaseYear) | \(genresDescription)"
    }
    var releaseYear: Int {
        let date = releaseDate.flatMap { Movie.dateFormatter.date(from: $0) } ?? Date()
        return Calendar.current.component(.year, from: date)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

