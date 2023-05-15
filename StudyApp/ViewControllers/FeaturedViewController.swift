import UIKit
import Combine
class FeaturedViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    //@IBOutlet weak var scrollView: UIScrollView!
   // @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    var list = ["Book1", "Book2", "Book3", "Book4"]
    @IBOutlet weak var courseTableview: UITableView!
    
    private var tokens: Set<AnyCancellable> = []
    private var lastScrollYPosition: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.layer.masksToBounds = false
        collectionView.publisher(for: \.contentSize).sink { contentSize in
            self.collectionViewHeight.constant = contentSize.height
        }.store(in: &tokens)
        
        courseTableview.dataSource = self
        courseTableview.delegate = self
        courseTableview.layer.masksToBounds = false
        courseTableview.publisher(for: \.contentSize).sink { contentSize in
            self.tableViewHeight.constant = contentSize.height
        }
        .store(in: &tokens)
    }
}


extension FeaturedViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func changeCollectionHeight() {
      //  collectionViewHeight.constant = collectionView.contentSize.height
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseCell", for: indexPath) as! HandbookCollectionViewCell
        return cell
    }
    
}

extension FeaturedViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.lastScrollYPosition = scrollView.contentOffset.y
        let totalScrollHeight = scrollView.contentSize.height
        let percentage = lastScrollYPosition / totalScrollHeight
        
        if percentage <= 0.1 {
            self.title = "Featured"
        } else if percentage <= 0.3 {
            self.title = "Handbooks"
        } else {
            self.title = "Courses"
        }
    }
}

extension FeaturedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        print("line spacing: 8")
        return 8
       }

       // 옆 간격
       func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           print("item spacing: 8")
           return 8
       }

       // cell 사이즈( 옆 라인을 고려하여 설정 )
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

           //let width = collectionView.frame.width / 2 - 1 ///  3등분하여 배치, 옆 간격이 1이므로 1을 빼줌
           let size = CGSize(width: 160, height: 257)
           return size
       }
}

extension FeaturedViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return courses.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseTableCell") as! CourseTableViewCell
        let course = courses[indexPath.section]
        cell.titleLabel.text = course.courseTitle
        cell.subtitleLabel.text = course.courseSubtitle
        cell.descriptionLabel.text = course.courseDescription
        cell.backgroundImage.image = course.courseBackground
        cell.courseBanner.image = course.courseBanner
        cell.courseLogo.image = course.courseIcon
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
