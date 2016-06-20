//
//  UIViewController+Extensions.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Benčević on 16/06/16.
//  Copyright © 2016 marinbenc. All rights reserved.
//

import UIKit

extension UIViewController {
    
    ///Presents a UIAlertController with a prefedined error message
    func presentError() {
        let alertController = UIAlertController(title: Text.Dialogues.errorTitle, message: Text.Dialogues.errorMessage, preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: Text.Dialogues.okayText, style: .Default, handler: nil)
        alertController.addAction(okayAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}