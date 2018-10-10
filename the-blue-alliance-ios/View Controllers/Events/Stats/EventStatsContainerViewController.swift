import Foundation
import CoreData
import TBAKit
import UIKit

class EventStatsContainerViewController: ContainerViewController {

    private let event: Event
    private let urlOpener: URLOpener
    private let userDefaults: UserDefaults

    private let teamStatsViewController: EventTeamStatsTableViewController

    lazy private var filerBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "ic_sort_white"),
                               style: .plain,
                               target: self,
                               action: #selector(showFilter))
    }()

    // MARK: - Init

    init(event: Event, urlOpener: URLOpener, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.urlOpener = urlOpener
        self.userDefaults = userDefaults

        teamStatsViewController = EventTeamStatsTableViewController(event: event, userDefaults: userDefaults, persistentContainer: persistentContainer)

        var eventStatsViewController: EventStatsViewController?
        // Only show event stats if year is 2016 or onward
        var titles = ["Team Stats"]
        if Int(event.year) >= 2016 {
            titles.append("Event Stats")
            eventStatsViewController = EventStatsViewController(event: event, persistentContainer: persistentContainer)
        }

        super.init(viewControllers: [teamStatsViewController, eventStatsViewController].compactMap({ $0 }),
                   segmentedControlTitles: titles,
                   persistentContainer: persistentContainer)

        navigationTitle = "Stats"
        navigationSubtitle = "@ \(event.friendlyNameWithYear)"

        navigationTitleDelegate = self
        teamStatsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Interface Actions

    @objc private func showFilter() {
        let selectTableViewController = SelectTableViewController<EventStatsContainerViewController>(current: teamStatsViewController.filter, options: EventTeamStatFilter.allCases, persistentContainer: persistentContainer)
        selectTableViewController.title = "Sort stats by"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissFilter))

        navigationController?.present(nav, animated: true, completion: nil)
    }

    @objc private func dismissFilter() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Container

    override func switchedToIndex(_ index: Int) {
        // Show filter button if we switched to the team stats view controller
        // Otherwise, hide the filter button
        if index == 0 {
            navigationItem.rightBarButtonItem = filerBarButtonItem
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

}

extension EventStatsContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        // Don't push to event if we just came from an Event
        if pushedFromEventViewController {
            return
        }

        let eventViewController = EventViewController(event: event, urlOpener: urlOpener, userDefaults: userDefaults, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

}

extension EventStatsContainerViewController: SelectTableViewControllerDelegate {

    typealias OptionType = EventTeamStatFilter

    func optionSelected(_ option: OptionType) {
        teamStatsViewController.filter = option
    }

    func titleForOption(_ option: OptionType) -> String {
        return option.rawValue
    }

}

extension EventStatsContainerViewController: EventTeamStatsSelectionDelegate {

    func eventTeamStatSelected(_ eventTeamStat: EventTeamStat) {
        let teamAtEventViewController = TeamAtEventViewController(team: eventTeamStat.team!, event: event, urlOpener: urlOpener, userDefaults: userDefaults, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
