//  UserFeedback.swift

/*
	Package MobileWallet
	Created by Jason van den Berg on 2020/01/23
	Using Swift 5.0
	Running on macOS 10.15

	Copyright 2019 The Tari Project

	Redistribution and use in source and binary forms, with or
	without modification, are permitted provided that the
	following conditions are met:

	1. Redistributions of source code must retain the above copyright notice,
	this list of conditions and the following disclaimer.

	2. Redistributions in binary form must reproduce the above
	copyright notice, this list of conditions and the following disclaimer in the
	documentation and/or other materials provided with the distribution.

	3. Neither the name of the copyright holder nor the names of
	its contributors may be used to endorse or promote products
	derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
	CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
	OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
	HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
	OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation
import SwiftEntryKit

class UserFeedback {
    static let shared = UserFeedback()

    func error(title: String, description: String, error: Error? = nil) {
        let errorFeedbackView = ErrorFeedback()

        var descriptionText = description
        if let e = error {
            descriptionText.append(" Error: \(e.localizedDescription)")
        }
        errorFeedbackView.setDetails(title: title, description: descriptionText)

        var attributes = EKAttributes.bottomFloat
        attributes.screenBackground = .color(color: EKColor(Theme.shared.colors.feedbackPopupBackground!))
        attributes.entryBackground = .clear
        attributes.positionConstraints.size = .init(width: .offset(value: 14), height: .intrinsic)
        attributes.positionConstraints.verticalOffset = 14
        attributes.screenInteraction = .dismiss
        attributes.displayDuration = 12
        attributes.roundCorners = .all(radius: 26)
        attributes.hapticFeedbackType = .error
        attributes.entryInteraction = .delayExit(by: 2)

        SwiftEntryKit.display(entry: errorFeedbackView, using: attributes)
    }
}
