//
//  ViewController.swift
//  BigProject
//
//  Created by NIX on 2016/11/18.
//  Copyright © 2016年 nixWork. All rights reserved.
//

import UIKit
import WorkerBee

class ViewController: UIViewController {

    var task: CancelableTask?

    let schedule = Schedule {
        print("schedule work", Date().timeIntervalSince1970)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Function.delay(3) {
            print("Task")
            SafeDispatch.async { [weak self] in
                self?.view.backgroundColor = .red
            }
        }

        task = CancelableTask(delay: 3) {
            print("CancelableTask")
        }

        Function.delay(2) { [weak self] in
            self?.task?.cancel()
        }

        let job = FreeTimeJob(target: self, selector: #selector(hardWork))
        job.commit()

        operate { value in
            print("or: value: \(value)")
        }

        do {
            let text = "Do not go gentle into that good night."
            let font = UIFont.systemFont(ofSize: 36)
            let width: CGFloat = 200
            let height = TextSize.height(text: text, font: font, width: width)
            let label = UILabel(frame: CGRect(x: 20, y: 100, width: width, height: height))
            label.font = font
            label.numberOfLines = 0
            label.backgroundColor = .green
            label.text = text
            view.addSubview(label)
        }

        do {
            let text = "Do not go gentle into that good night."
            let font = UIFont.systemFont(ofSize: 17)
            let height: CGFloat = 30
            let width = TextSize.width(text: text, font: font, insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
            let label = UILabel(frame: CGRect(x: 20, y: 300, width: width, height: height))
            label.font = font
            label.textAlignment = .center
            label.backgroundColor = .blue
            label.text = text
            view.addSubview(label)
        }

        let deepLinkRecognizer = DeepLinkRecognizer(
            deepLinkTypes: [
                ShowCircleDeepLink.self,
                AppStoreAppDeepLink.self
            ]
        )
        let urls: [URL] = [
            URL(string: "https://share.quanziapp.com/circle/sVBgoaB")!,
            URL(string: "https://itunes.apple.com/cn/app/apple-store/id375380948?pt=2003&ct=footer&mt=8")!,
            URL(string: "https://itunes.apple.com/cn/app/apple-store/id375380948?pt=2003")!,
            URL(string: "https://google.com")!
        ]
        urls.forEach { url in
            if let deepLink = deepLinkRecognizer.deepLink(matching: url) {
                switch deepLink {
                case let showCircleDeepLink as ShowCircleDeepLink:
                    print("showCircleDeepLink", showCircleDeepLink)
                case let appStoreAppDeepLink as AppStoreAppDeepLink:
                    print("appStoreAppDeepLink", appStoreAppDeepLink)
                default:
                    print("url", url)
                }
            } else {
                print("url", url)
            }
        }

        schedule.start(timeInterval: .seconds(1), repeats: true)
    }

    @objc func hardWork() {
        // TODO: hardWork
    }

    func operate(work: @escaping (Int) -> Void) {
        let or = OperatingRoom()
        var value = 0
        or.prepare { finish in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                print("or: delay 2")
                value = 2
                finish()
            }
        }
        or.prepare { finish in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                print("or: delay 5")
                value = 5
                finish()
            }
        }
        or.ready {
            print("or: go go go")
            work(value)
        }
    }
}

struct ShowCircleDeepLink: DeepLink {

    static let template = DeepLinkTemplate()
        .term("share.quanziapp.com")
        .term("circle")
        .string(named: "circleIdentifier")
        .queryStringParameter(.optionalString(named: "from"))

    init(values: DeepLinkValues) {
        self.circleIdentifier = values.path["circleIdentifier"] as! String
        self.from = values.query["from"] as? String
    }

    let circleIdentifier: String
    let from: String?
}

struct AppStoreAppDeepLink: DeepLink {

    static let template = DeepLinkTemplate()
        .term("itunes.apple.com")
        .term("cn")
        .term("app")
        .term("apple-store")
        .string(named: "id")
        .queryStringParameters([
            .requiredInt(named: "pt"),
            .optionalString(named: "ct"),
            .optionalInt(named: "mt")
            ])

    init(values: DeepLinkValues) {
        self.id = values.path["id"] as! String
        self.pt = values.query["pt"] as! Int
        self.ct = values.query["ct"] as? String
        self.mt = values.query["mt"] as? Int
    }

    let id: String
    let pt: Int
    let ct: String?
    let mt: Int?
}
