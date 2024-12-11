//
//  StepbyStepVC.swift
//  HintsightFHE
//
//  Created by Luo Kaiwen on 2/12/24.
//

import UIKit

class StepbyStepPVC: UIPageViewController {
    
    var pages = [UIViewController]()
    var face: UIImage?
    var featuresString = ""
    var encryptedFeaturesString = ""
    var screenHeight = 0.0
    var screenWidth = 0.0
    var encryptedResultString = ""
    var decryptedResultString = ""
    
    //external controls
    let prevButton = UIButton()
    let nextButton = UIButton()
    let testButton = UIButton()
    let pageControl = UIPageControl()
    let initialPage = 0
    
    //animations
    var prevButtonTopAnchor: NSLayoutConstraint?
    var nextButtonTopAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(pageControl, prevButton, nextButton)
        
        configurePageViews()
        configureControls()
        configureControlLayouts()
    }
}

extension StepbyStepPVC {
    
    func configurePageViews() {
        dataSource = self
        delegate = self
        pageControl.addTarget(self, action: #selector(pageControlTapped), for: .valueChanged)
        
        let step1 = Step1VC(face: face, feature: featuresString, screenHeight: screenHeight, screenWidth: screenWidth)
        let step2 = Step2VC(features: featuresString, encryptedFeatures: encryptedFeaturesString,
                            screenHeight: screenHeight, screenWidth: screenWidth)
        let step3 = Step3VC(screenHeight: screenHeight, screenWidth: screenWidth)
        let step4 = Step4VC(encryptedResult: encryptedResultString, decryptedResult: decryptedResultString,
                            screenHeight: screenHeight, screenWidth: screenWidth)
        
        pages.append(step1)
        pages.append(step2)
        pages.append(step3)
        pages.append(step4)
        
        setViewControllers([pages[initialPage]], direction: .forward, animated: false)
    }
    
    @objc func pageControlTapped(_ sender: UIPageControl) {
        setViewControllers([pages[sender.currentPage]], direction: .forward, animated: false)
    }
    
    @objc func nextTapped(_ sender: UIButton) {
        pageControl.currentPage += 1
        toNextPage()
        animateControlsIfNeeded()
    }
    
    @objc func prevTapped(_ sender: UIButton) {
        pageControl.currentPage -= 1
        toPreviousPage()
        animateControlsIfNeeded()
    }
    
    func configureControls() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColor(hexString: Colors.blue.rawValue, alpha: 1) ?? .white
        pageControl.pageIndicatorTintColor = .systemGray5
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = initialPage
        
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.isHidden = true
        prevButton.setTitleColor(UIColor(hexString: Colors.blue.rawValue, alpha: 1) ?? .systemBlue, for: .normal)
        prevButton.setTitle("Previous", for: .normal)
        prevButton.addTarget(self, action: #selector(prevTapped), for: .primaryActionTriggered)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitleColor(UIColor(hexString: Colors.blue.rawValue, alpha: 1) ?? .systemBlue, for: .normal)
        nextButton.setTitle("Next", for: .normal)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .primaryActionTriggered)
    }
    
    func configureControlLayouts() {
        NSLayoutConstraint.activate([
            pageControl.widthAnchor.constraint(equalTo: view.widthAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: pageControl.bottomAnchor, multiplier: 2),
            
            prevButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: nextButton.trailingAnchor, multiplier: 2)
        ])
        
        prevButtonTopAnchor = prevButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: -2)
        nextButtonTopAnchor = nextButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: -2)
        
        prevButtonTopAnchor?.isActive = true
        nextButtonTopAnchor?.isActive = true
    }
}

extension StepbyStepPVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentPage = pages.firstIndex(of: viewController) else { return nil}
        
        if currentPage == 0 {
            return pages.last
        } else {
            return pages[currentPage - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentPage = pages.firstIndex(of: viewController) else { return nil }
        
        if currentPage == pages.count-1 {
            return pages.first
        } else {
            return pages[currentPage + 1]
        }
    }
    
}

extension StepbyStepPVC: UIPageViewControllerDelegate {
    
    //keep pageControl (dots at the bottom)  in sync with viewControllers
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let currentPage = pages.firstIndex(of: viewControllers[0]) else { return }
        
        pageControl.currentPage = currentPage
        animateControlsIfNeeded()
    }
    
    private func animateControlsIfNeeded() {
        let firstPage = pageControl.currentPage == 0
        let lastPage = pageControl.currentPage == pages.count - 1
  
        if firstPage { prevButton.isHidden = true } else { prevButton.isHidden = false }
        if lastPage { nextButton.isHidden = true } else { nextButton.isHidden = false }
    }
}

extension UIPageViewController {
    
    func toNextPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard let currentPage = viewControllers?[0] else { return }
        guard let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentPage) else { return }
        
        setViewControllers([nextPage], direction: .forward, animated: animated, completion: completion)
    }
    
    func toPreviousPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard let currentPage = viewControllers?[0] else { return }
        guard let prevPage = dataSource?.pageViewController(self, viewControllerBefore: currentPage) else { return }
        
        setViewControllers([prevPage], direction: .reverse, animated: animated, completion: completion)
    }
    
    func toSpecificPage(index: Int, pages: [UIViewController]) {
        setViewControllers([pages[index]], direction: .forward, animated: false, completion: nil)
    }
}
