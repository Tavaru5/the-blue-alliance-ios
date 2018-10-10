import CoreData
import Foundation
import UIKit

class MatchContainerViewController: ContainerViewController {

    private let match: Match
    private let team: Team?
    private let urlOpener: URLOpener
    private let userDefaults: UserDefaults

    // MARK: Init

    init(match: Match, team: Team? = nil, urlOpener: URLOpener, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer) {
        self.match = match
        self.team = team
        self.urlOpener = urlOpener
        self.userDefaults = userDefaults

        let infoViewController = MatchInfoViewController(match: match, team: team, persistentContainer: persistentContainer)

        // Only show match breakdown if year is 2015 or onward
        var breakdownViewController: MatchBreakdownViewController?
        var titles: [String]  = ["Info"]
        if Int(match.event!.year) >= 2015 {
            titles.append("Breakdown")
            breakdownViewController = MatchBreakdownViewController(match: match, persistentContainer: persistentContainer)
        }

        super.init(viewControllers: [infoViewController, breakdownViewController].compactMap({ $0 }) as! [ContainableViewController],
                   segmentedControlTitles: titles,
                   persistentContainer: persistentContainer)

        navigationTitle = "\(match.friendlyMatchName())"
        navigationSubtitle = "@ \(match.event!.friendlyNameWithYear)"

        navigationTitleDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension MatchContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        // Don't push to event if we just came from an Event
        if pushedFromEventViewController {
            return
        }

        let eventViewController = EventViewController(event: match.event!, urlOpener: urlOpener, userDefaults: userDefaults, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

}
