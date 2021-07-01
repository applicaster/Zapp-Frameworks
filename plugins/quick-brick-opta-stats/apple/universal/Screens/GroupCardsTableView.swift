//
//  GroupCardsTableView.swift
//  OptaStats
//
//  Created by Alex Zchut on 01/07/2021.
//

import Foundation
import MBProgressHUD
import RxSwift

class GroupCardsTableView: UITableView, GroupCardTableViewCellDelegate {
    @IBOutlet var heightConstraint: NSLayoutConstraint!

    fileprivate var divisions = [Division]()
    fileprivate var cellHeightShouldBeExpanded = [Int: Bool]()
    fileprivate var expandedCellHeight: CGFloat = 0.0
    fileprivate var cellTemplate: GroupCardTableViewCell!

    lazy var groupCardViewModel: GroupCardsViewModel = {
        GroupCardsViewModel()
    }()

    let bag = DisposeBag()
    var parent: ViewControllerBase?

    func setup(with parent: ViewControllerBase?) {
        self.parent = parent
        dataSource = self
        delegate = self
        register(UINib(nibName: "GroupCardTableViewCell",
                       bundle: Bundle(for: classForCoder)),
                 forCellReuseIdentifier: "GroupCardTableViewCell")

        cellTemplate = dequeueReusableCell(withIdentifier: "GroupCardTableViewCell") as? GroupCardTableViewCell

        subscribe()
        groupCardViewModel.fetch()
    }

    fileprivate func subscribe() {
        groupCardViewModel.isLoading.asObservable()
            .subscribe(onNext: { [unowned self] isLoading in
                if isLoading {
                    MBProgressHUD.showAdded(to: self, animated: true)
                } else {
                    MBProgressHUD.hide(for: self, animated: true)
                }
            }, onError: { [unowned self] _ in
                MBProgressHUD.hide(for: self, animated: true)
            }).disposed(by: bag)

        groupCardViewModel.groupCard.asObservable().subscribe(onNext: { [unowned self] _ in
            self.processGroupCardViewModel()
            self.reloadData()
            self.heightConstraint.constant = self.contentSize.height
        }).disposed(by: bag)
    }

    fileprivate func processGroupCardViewModel() {
        if let model = groupCardViewModel.groupCard.value {
            if let divitions = model.stage.divisions {
                divisions = divitions.filter {
                    $0.type == "total"
                }
            }
        }
    }

    fileprivate func saveCellExpandedState(index: Int) {
        if let currentVal = cellHeightShouldBeExpanded[index] {
            cellHeightShouldBeExpanded[index] = !currentVal
        } else {
            cellHeightShouldBeExpanded[index] = true
        }
    }
}

extension GroupCardsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row selected")
    }
}

extension GroupCardsTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return divisions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCardTableViewCell") as! GroupCardTableViewCell

        let division = divisions[indexPath.row]
        cell.tag = indexPath.row
        cell.didTapOnTeamFlag = { [weak self] teamId in
            self?.parent?.showTeamScreen(teamID: teamId)
        }
        cell.didTapOnToggleExpand = { [weak self] index in
            self?.saveCellExpandedState(index: index)
        }
        cell.division = division
        cell.cellDelegate = self
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellTemplate.cellHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = tableView.cellForRow(at: indexPath) as? GroupCardTableViewCell {
            if cell.cellHeight > cellTemplate.cellHeight {
                expandedCellHeight = cell.cellHeight
            }
        }

        if let expanded = cellHeightShouldBeExpanded[indexPath.row] {
            if expanded {
                setNeedsLayout()
                return expandedCellHeight
            } else {
                setNeedsLayout()
                return cellTemplate.cellHeight
            }
        }

        setNeedsLayout()
        return cellTemplate.cellHeight
    }

    // MARK: -

    func groupCardTableViewCellUpdateExpanding(cell: GroupCardTableViewCell) {
        beginUpdates()
        endUpdates()
    }
}
