import UIKit
import Combine

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    var movieId: Int = 0
    let viewModel = MovieDetailViewModel()
    var cancelable: Set<AnyCancellable> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black
        viewModel.fetchMovie(id: movieId)
        viewModel.$state.sink { [unowned self] state in
            switch state {
            case .loading:
                print("loading")
            case .success(let model):
                self.render(viewModel: model)
            case .failure(let error):
                print("failure: \(error)")
            }
        }
        .store(in: &cancelable)
    }
    
    private func render(viewModel: MovieViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        overviewLabel.text = viewModel.overview

        viewModel.poster.sink { [unowned self] image in
            showImage(image: image)
        }.store(in: &cancelable)
    }
    
    private func showImage(image: UIImage?) {
        postImage.image = image
    }
}
