//  LAContext.swift

/*
	Package MobileWallet
	Created by Gabriel Lupu on 08/02/2020
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
import UIKit
import LocalAuthentication

extension LAContext {
    enum BiometricType: String {
        case none
        case touchID
        case faceID
        case pin
    }

    enum AuthenticateUserReason {
        case logIn
        case userVerification

        var rawValue: String {
            switch self {
            case .logIn: return NSLocalizedString("authentication.reason.login", comment: "Authentication")
            case .userVerification: return NSLocalizedString("authentication.reason.user_verification", comment: "Authentication")
            }
        }
    }

    var biometricType: BiometricType {
        if  self.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            if  self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                if biometryType == .faceID {
                    return .faceID
                }
                if biometryType == .touchID {
                    return .touchID
                }
            }
            return .pin
        } else {
            return .none
        }
    }

    func authenticateUser(reason: AuthenticateUserReason = .logIn, onSuccess: @escaping () -> Void) {
        #if targetEnvironment(simulator)
        //Skip auth on simulator, quicker for development
        onSuccess()
        return
        #endif

        switch biometricType {
        case .faceID, .touchID, .pin:
            let policy: LAPolicy = biometricType == .pin ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
            let localizedReason = reason.rawValue
            evaluatePolicy(policy, localizedReason: localizedReason) {
                [weak self] success, error in

                DispatchQueue.main.async { [weak self] in
                    if success {
                        onSuccess()
                    } else {
                        let localizedReason = error?.localizedDescription ?? NSLocalizedString("authentication.fail.description", comment: "Authentication")
                        TariLogger.error("Biometrics auth failed", error: error)
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.authenticationFailedAlertOptions(reason: localizedReason, onSuccess: onSuccess)
                        }
                    }
                }
            }
        case .none:
            let alert = UIAlertController(title: NSLocalizedString("authentication.error.title", comment: "Authentication") ,
                                          message: NSLocalizedString("authentication.error.description", comment: "Authentication"),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("authentication.try_again", comment: "Authentication"),
                                          style: .cancel,
                                          handler: { [weak self] _ in
                                            self?.authenticateUser(onSuccess: onSuccess)
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("authentication.proceed", comment: "Authentication"), style: .default, handler: { _ in
                onSuccess()
            }))

            if let topController = UIApplication.shared.topController() {
                topController.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func authenticationFailedAlertOptions(reason: String, onSuccess: @escaping () -> Void) {
        let alert = UIAlertController(title: NSLocalizedString("authentication.fail.title", comment: "Authentication"), message: reason, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Try again", comment: "Authentication"), style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.authenticateUser(onSuccess: onSuccess)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("authentication.action.open_settings", comment: "Authentication"), style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.openAppSettings()
        }))

        if let topController = UIApplication.shared.topController() {
            topController.present(alert, animated: true, completion: nil)
        }
    }

    private func openAppSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings)
        }
    }
}
