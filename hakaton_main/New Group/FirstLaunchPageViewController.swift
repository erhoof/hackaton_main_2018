//
//  FirstLaunchPageViewController.swift
//  hakaton_main
//
//  Created by Pavel Bibichenko on 27/10/2018.
//  Copyright © 2018 Pavel Bibichenko. All rights reserved.
//

import UIKit

class FirstLaunchPageViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        
        if let firstVC = pages.first
        {
            setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }
        
    }

    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: "Tutorial1"),
            self.getViewController(withIdentifier: "Tutorial2"),
            self.getViewController(withIdentifier: "Tutorial3"),
            self.getViewController(withIdentifier: "Tutorial4")
        ]
    }()
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
}

extension FirstLaunchPageViewController: UIPageViewControllerDataSource
{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return pages.last }
        
        guard pages.count > previousIndex else { return nil        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return pages.first }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
}

extension FirstLaunchPageViewController: UIPageViewControllerDelegate { }
