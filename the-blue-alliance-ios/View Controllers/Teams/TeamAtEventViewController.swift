import Foundation
import CoreData
import UIKit

class TeamAtEventViewController: ContainerViewController {

    private let team: Team
    private let event: Event
    private let urlOpener: URLOpener
    private let userDefaults: UserDefaults

    // MARK: - Init

    init(team: Team, event: Event, urlOpener: URLOpener, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer) {
        self.team = team
        self.event = event
        self.urlOpener = urlOpener
        self.userDefaults = userDefaults

        let summaryViewController: TeamSummaryViewController = TeamSummaryViewController(team: team, event: event, persistentContainer: persistentContainer)
        let matchesViewController: MatchesViewController = MatchesViewController(event: event, team: team, persistentContainer: persistentContainer)
        let statsViewController: TeamStatsViewController = TeamStatsViewController(team: team, event: event, persistentContainer: persistentContainer)
        let awardsViewController: EventAwardsViewController = EventAwardsViewController(event: event, team: team, persistentContainer: persistentContainer)

        super.init(viewControllers: [summaryViewController, matchesViewController, statsViewController, awardsViewController],
                   segmentedControlTitles: ["Summary", "Matches", "Stats", "Awards"],
                   persistentContainer: persistentContainer)

        navigationTitle = "Team \(team.teamNumber)"
        navigationSubtitle = "@ \(event.friendlyNameWithYear)"

        navigationTitleDelegate = self
        summaryViewController.delegate = self
        matchesViewController.delegate = self
        awardsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension TeamAtEventViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        // Don't push to event if we just came from an Event
        if pushedFromEventViewController {
            return
        }

        let eventViewController = EventViewController(event: event, urlOpener: urlOpener, userDefaults: userDefaults, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

}

extension TeamAtEventViewController: MatchesViewControllerDelegate, TeamSummaryViewControllerDelegate {

    func awardsSelected() {
        let awardsViewController = EventAwardsContainerViewController(event: event, team: team, urlOpener: urlOpener, userDefaults: userDefaults, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(awardsViewController, animated: true)
    }

    func matchSelected(_ match: Match) {
        let matchViewController = MatchContainerViewController(match: match, team: team, urlOpener: urlOpener, userDefaults: userDefaults, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}

extension TeamAtEventViewController: EventAwardsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        // Don't push to team@event for team we're already showing team@event for
        if self.team == team {
            return
        }

        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, urlOpener: urlOpener, userDefaults: userDefaults, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
