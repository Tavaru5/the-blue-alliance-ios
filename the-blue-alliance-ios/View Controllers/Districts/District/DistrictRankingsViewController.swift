import Foundation
import UIKit
import CoreData

protocol DistrictRankingsViewControllerDelegate: AnyObject {
    func districtRankingSelected(_ districtRanking: DistrictRanking)
}

class DistrictRankingsViewController: TBATableViewController {

    private let district: District

    weak var delegate: DistrictRankingsViewControllerDelegate?
    private var dataSource: TableViewDataSource<DistrictRanking, DistrictRankingsViewController>!

    // MARK: - Init

    init(district: District, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.district = district

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ranking = dataSource.object(at: indexPath)
        delegate?.districtRankingSelected(ranking)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<DistrictRanking> = DistrictRanking.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<DistrictRanking>) {
        request.predicate = NSPredicate(format: "district == %@", district)
    }

}

extension DistrictRankingsViewController: TableViewDataSourceDelegate {

    func configure(_ cell: RankingTableViewCell, for object: DistrictRanking, at indexPath: IndexPath) {
        cell.viewModel = RankingCellViewModel(districtRanking: object)
    }

}

extension DistrictRankingsViewController: Refreshable {

    var refreshKey: String? {
        return "\(district.key!)_rankings"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh district rankings until DCMP is over
        return district.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        if let rankings = dataSource.fetchedResultsController.fetchedObjects, rankings.isEmpty {
            return true
        }
        return false
    }

    // TODO: Think about building a way to "chain" requests together for a refresh...
    @objc func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = tbaKit.fetchDistrictRankings(key: district.key!, completion: { (rankings, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let rankings = rankings {
                    let district = context.object(with: self.district.objectID) as! District
                    district.insert(rankings)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)
        })
        addRequest(request: request!)
    }

}

extension DistrictRankingsViewController: Stateful {

    var noDataText: String {
        return "No rankings for district"
    }

}
