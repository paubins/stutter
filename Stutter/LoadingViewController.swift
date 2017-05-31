//
//  LoadingViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import ParticlesLoadingView

class LoadingViewController : UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadingView:ParticlesLoadingView = ParticlesLoadingView(frame: .zero)
        loadingView.particleEffect = .spark
        loadingView.duration = 1.5
        loadingView.layer.cornerRadius = 15.0
        
        self.view.addSubview(loadingView)
    }

}
