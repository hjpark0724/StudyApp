import UIKit
import Combine
class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    var cancelable: AnyCancellable?
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelLoding()
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(to viewModel: MovieViewModel) {
        cancelLoding()
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        cancelable = viewModel.poster.sink(receiveValue: { [unowned self] image in
            self.showImage(image: image)
        })
    }
    
    private func showImage(image: UIImage?) {
            self.cancelLoding()
            UIView.transition(with: self.thumbnail,
            duration: 0.3,
            options: [.curveEaseOut, .transitionCrossDissolve],
            animations: {
                self.thumbnail.image = image
            })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    private func cancelLoding() {
        thumbnail.image = nil
        cancelable?.cancel()
    }

}
