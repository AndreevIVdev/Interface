//
//  ViewController.swift
//  Interface
//
//  Created by Илья Андреев on 15.02.2022.
//

import UIKit

enum Mock {
    static let cornerRadius: CGFloat = 10
    static let title = "Visa"
    static let padding: CGFloat = 20
    static let miniPadding: CGFloat = 5
    static let currentPriceLabelText = "220.09 $"
    static let currentPriceLabelFontSize: CGFloat = 20
    static let changePriceLabelText = "+18.01 $ (8.3%)"
    static let changePriceLabelFontSize: CGFloat = 14
    static let chartImageHeight: CGFloat = 340
    static let periodsSegmentedControlItems: [String] = ["Д", "Н", "М", "6М", "1Г", "Всё"]
    static let periodsSegmentedControlHeight: CGFloat = 30
    static let infoViewHeight: CGFloat = 400
    static let infoViewFontSize: CGFloat = 14
    static let buttonMinimumHeight: CGFloat = 55
    static let actionButtonToWidthMultiplier: CGFloat = 0.43
    static let dataSourcePrice: InfoViewDataSource =
        .init(labelText: "Стоимость", rows: [("Открытие", "100Р"), ("Минимум", "90Р"), ("Тикер", "AMCO")])
    static let dataSourceAccount: InfoViewDataSource =
        .init(
            labelText: "Портфель",
            rows: [("Количество", "100"), ("Общая стоимость", "9000Р"), ("Дельта", "-1000Р (-10%)")]
        )
    static let sellButtonTitle: String = "Продать"
    static let buyButtonTitle: String = "Купить"
    static let buttonTitleTextFontSize: CGFloat = 16
}

struct InfoViewDataSource {
    let labelText: String
    let rows: [(String, String)]
}

class ViewController: UIViewController {
    private let headerView: UIView = .init()
    private let footerView: UIView = .init()
    private let currentPriceLabel: UILabel = .init()
    private let changePriceLabel: UILabel = .init()
    private let chartView: ChartView = .init()
    private let timeframeSegmentedControl: UISegmentedControl = .init()
    private let infoTableView: UITableView = .init(frame: .zero, style: .insetGrouped)
    private let buyButton: UIButton = .init()
    private let sellButton: UIButton = .init()
    private var headerViewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureInfoTableView()
        
        configureHeaderView()
        configureCurrentPriceLabel()
        configureChangePriceLabel()
        configureChartView()
        configurePeriodsSegmentedControl()
        configureTableHeaderView()
        
        configureFooterView()
        configureSellButton()
        configureBuyButton()
        configureTableFooterView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chartView.dataSource = MockDataSource().generateRandomEntries()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

extension ViewController {
    
    private func configureViewController() {
        view.backgroundColor = .black
        title = Mock.title
        view.addSubViews(infoTableView)
    }
    
    private func configureInfoTableView() {
        infoTableView.translatesAutoresizingMaskIntoConstraints = false
        infoTableView.register(InfoTableViewCell.self, forCellReuseIdentifier: InfoTableViewCell.description())
        infoTableView.delegate = self
        infoTableView.dataSource = self
        NSLayoutConstraint.activate([
            infoTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            infoTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            infoTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController {
    
    private func configureHeaderView() {
        headerView.addSubViews(currentPriceLabel, changePriceLabel, chartView, timeframeSegmentedControl)
    }
    
    private func configureCurrentPriceLabel() {
        currentPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        currentPriceLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        currentPriceLabel.text = Mock.currentPriceLabelText
        currentPriceLabel.sizeToFit()
        
        NSLayoutConstraint.activate([
            currentPriceLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Mock.padding),
            currentPriceLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: Mock.padding)
        ])
    }
    
    private func configureChangePriceLabel() {
        changePriceLabel.translatesAutoresizingMaskIntoConstraints = false
        changePriceLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        changePriceLabel.text = Mock.changePriceLabelText
        changePriceLabel.sizeToFit()
        
        NSLayoutConstraint.activate([
            changePriceLabel.leadingAnchor.constraint(equalTo: currentPriceLabel.leadingAnchor),
            changePriceLabel.topAnchor.constraint(equalTo: currentPriceLabel.bottomAnchor, constant: Mock.miniPadding)
        ])
    }
    
    private func configureChartView() {
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.tintColor = .white
        chartView.contentMode = .scaleAspectFill
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            chartView.topAnchor.constraint(equalTo: changePriceLabel.bottomAnchor, constant: Mock.padding),
            chartView.heightAnchor.constraint(equalToConstant: Mock.chartImageHeight)
        ])
    }
    
    private func configurePeriodsSegmentedControl() {
        timeframeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        Mock.periodsSegmentedControlItems.enumerated().forEach {
            timeframeSegmentedControl.insertSegment(withTitle: $0.element, at: $0.offset, animated: true)
        }
        
        NSLayoutConstraint.activate([
            timeframeSegmentedControl.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor,
                constant: Mock.padding
            ),
            timeframeSegmentedControl.trailingAnchor.constraint(
                equalTo: headerView.trailingAnchor, constant: -Mock.padding
            ),
            timeframeSegmentedControl.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: Mock.padding),
            timeframeSegmentedControl.heightAnchor.constraint(equalToConstant: Mock.periodsSegmentedControlHeight),
            timeframeSegmentedControl.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -Mock.padding)
        ])
    }
    
    private func configureTableHeaderView() {
        infoTableView.tableHeaderView = headerView
        headerView.frame.size.height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
}

extension ViewController {
    
    private func configureFooterView() {
        footerView.addSubViews(buyButton, sellButton)
    }
    
    private func configureSellButton() {
        sellButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sellButton.heightAnchor.constraint(equalToConstant: Mock.buttonMinimumHeight),
            sellButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: Mock.padding),
            sellButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: Mock.padding),
            sellButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -Mock.padding),
            sellButton.widthAnchor.constraint(
                equalTo: footerView.widthAnchor, multiplier: Mock.actionButtonToWidthMultiplier
            )
        ])
        
        sellButton.backgroundColor = .systemRed
        sellButton.layer.cornerRadius = Mock.cornerRadius
        sellButton.setTitle(Mock.sellButtonTitle, for: .normal)
        sellButton.titleLabel?.font = UIFont.systemFont(ofSize: Mock.buttonTitleTextFontSize, weight: .bold)
    }
    
    private func configureBuyButton() {
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buyButton.heightAnchor.constraint(equalToConstant: Mock.buttonMinimumHeight),
            buyButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -Mock.padding),
            buyButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: Mock.padding),
            buyButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -Mock.padding),
            buyButton.widthAnchor.constraint(equalTo: sellButton.widthAnchor)
        ])
        
        buyButton.backgroundColor = .systemGreen
        buyButton.layer.cornerRadius = Mock.cornerRadius
        buyButton.setTitle(Mock.buyButtonTitle, for: .normal)
        buyButton.titleLabel?.font = UIFont.systemFont(ofSize: Mock.buttonTitleTextFontSize, weight: .bold)
    }
    
    private func configureTableFooterView() {
        infoTableView.tableFooterView = footerView
        footerView.frame.size.height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
}

extension ViewController: UITableViewDelegate {}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.description(), for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = Mock.dataSourcePrice.rows[indexPath.row].0
            cell.detailTextLabel?.text = Mock.dataSourcePrice.rows[indexPath.row].1
        } else {
            cell.textLabel?.text = Mock.dataSourceAccount.rows[indexPath.row].0
            cell.detailTextLabel?.text = Mock.dataSourceAccount.rows[indexPath.row].1
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? Mock.dataSourcePrice.labelText : Mock.dataSourceAccount.labelText
    }
}

class InfoTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    func addSubViews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}
