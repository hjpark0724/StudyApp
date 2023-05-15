import UIKit
import Combine
class SearchViewController: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    var cancelable: Set<AnyCancellable> = []
    var viewModel = MoviesViewModel()
    var search = PassthroughSubject<String, Never>()
    private lazy var dataSource = makeDataSource()
    let searchController = UISearchController(searchResultsController: nil)
    var loadingViewController: LoadingViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        loadingViewController = storyBoard.instantiateViewController(identifier: "LoadingViewController")
        
        
        self.navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .label
        searchController.searchBar.delegate = self
        add(loadingViewController!)
        tableview.delegate = self
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchController.searchBar.searchTextField)
            .compactMap({ ($0.object as! UITextField).text})
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink(receiveValue: {[unowned self] query in
                viewModel.fetch(query: query)
             })
            .store(in: &cancelable)
        
        viewModel.$state.sink{ [unowned self] state in
            render(state: state)
        }
        .store(in: &cancelable)
    }
    
    private func render(state: MoviesSearchState) {
        switch state {
        case .idle:
            loadingViewController?.view.isHidden = false
            loadingViewController?.titleLabel.text = "검색할 내용을 입력하세요"
            loadingViewController?.descriptionLabel.text = ""
            update(with: [], animate: false)
        case .loading:
            loadingViewController?.view.isHidden = false
            loadingViewController?.titleLabel.text = "검색중입니다"
            loadingViewController?.descriptionLabel.text = ""
            update(with: [], animate: false)
        case .success(let movies):
            loadingViewController?.view.isHidden = true
            update(with: movies, animate: true)
        case .noResults:
            loadingViewController?.view.isHidden = false
            loadingViewController?.titleLabel.text = "검색결과 없음"
            loadingViewController?.descriptionLabel.text = ""
            update(with: [], animate: false)
        default:
            loadingViewController?.view.isHidden = false
            loadingViewController?.titleLabel.text = ""
            loadingViewController?.descriptionLabel.text = ""
            update(with: [], animate: false)
        }
    }
    
    func update(with movies: [MovieViewModel], animate: Bool = true) {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<Section, MovieViewModel>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(movies, toSection: .movies)
            self.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.fetch(query: "")
    }
}

extension SearchViewController {
    enum Section: CaseIterable {
        case movies
    }
    
    func makeDataSource() -> UITableViewDiffableDataSource<Section, MovieViewModel> {
        return UITableViewDiffableDataSource(
            tableView: tableview,
            cellProvider: {  tableview, indexPath, movieViewModel in
                guard let cell = tableview.dequeueReusableCell(withIdentifier: "MovieCell") as? MovieTableViewCell else {
                    assertionFailure("Failed to dequeue \(MovieTableViewCell.self)!")
                    return UITableViewCell()
                }
                cell.bind(to: movieViewModel)
                return cell
            }
        )
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        //selection.send(snapshot.itemIdentifiers[indexPath.row].id)
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        let id = snapshot.itemIdentifiers[indexPath.row].id
        controller.movieId = id
        navigationController?.pushViewController(controller, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
}
