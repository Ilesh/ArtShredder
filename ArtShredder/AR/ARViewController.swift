//
//  ARViewController.swift
//  ArtShredder
//
//  Created by marty-suzuki on 2018/10/16.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import ARKit
import GoogleMobileAds
import Prex
import SceneKit
import UIKit

final class ARViewController: UIViewController {

    @IBOutlet private(set) weak var sceneView: ARSCNView!
    @IBOutlet private(set) weak var bannerContainerView: UIView! {
        didSet {
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            bannerContainerView.addSubview(bannerView)
            bannerContainerView.addConstraints(
                [NSLayoutConstraint(item: bannerView,
                                    attribute: .top,
                                    relatedBy: .equal,
                                    toItem: bannerContainerView,
                                    attribute: .top,
                                    multiplier: 1,
                                    constant: 0),
                 NSLayoutConstraint(item: bannerView,
                                    attribute: .centerX,
                                    relatedBy: .equal,
                                    toItem: bannerContainerView,
                                    attribute: .centerX,
                                    multiplier: 1,
                                    constant: 0)
                ])
        }
    }
    @IBOutlet private(set) weak var selectImageButton: UIButton! {
        didSet {
            let title = NSLocalizedString("select_to_add_art_title", comment: "")
            selectImageButton.setTitle(title, for: .normal)
            selectImageButton.layer.borderWidth = 2
            selectImageButton.layer.borderColor = UIColor.white.cgColor
            selectImageButton.layer.cornerRadius = 4
            selectImageButton.layer.masksToBounds = true
        }
    }

    private lazy var bannerView: GADBannerView = {
        let view = GADBannerView(adSize: kGADAdSizeBanner)
        view.adUnitID = AdMobConfig.make().bannerAdID
        view.rootViewController = self
        view.load(GADRequest())
        return view
    }()

    private lazy var presenter = ARPresenter(view: self)
    private lazy var delegateProxy = ARViewDelegateProxy(presenter: presenter,
                                                         pointOfView: { [weak self] in self?.sceneView.pointOfView })

    override var prefersStatusBarHidden: Bool {
        return true
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.reflect()

        bannerView.delegate = delegateProxy
        sceneView.delegate = delegateProxy
        sceneView.scene = SCNScene()
        sceneView.debugOptions = .showFeaturePoints

        _ = bannerView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    @IBAction private func doneTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func selectTap(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = delegateProxy
            picker.modalPresentationStyle = .overFullScreen
            present(picker, animated: true, completion: nil)
        }
    }
}

extension ARViewController: View {
    func reflect(change: StateChange<AR.State>) {
        if let isHidden = change.changedProperty(for: \.isImageSelectHidden)?.value {
            selectImageButton.isHidden = isHidden
        }

        if let node = change.changedProperty(for: \.shredderNode)?.value {
            sceneView.scene.rootNode.addChildNode(node)
            sceneView.debugOptions = []
        }
    }
}
