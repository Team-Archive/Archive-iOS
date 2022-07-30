//
//  LoginInformationReactor.swift
//  Archive
//
//  Created by hanwe on 2021/10/23.
//

import ReactorKit
import RxSwift
import RxRelay
import RxFlow

class LoginInformationReactor: Reactor, Stepper {
    // MARK: private property
    
    private let type: LoginType
    private let email: String
    private let archiveCnt: Int
    private let validator: Validator
    private let findPasswordUsecase: FindPasswordUsecase
    
    // MARK: internal property
    
    let steps = PublishRelay<Step>()
    let initialState = State()
    var error: PublishSubject<String>
    var toastMessage: PublishSubject<String>
    
    // MARK: lifeCycle
    
    init(loginInfo: MyLoginInfo, archiveCnt: Int, validator: Validator, findPasswordUsecase: FindPasswordUsecase) {
        self.type = loginInfo.loginType
        self.email = loginInfo.email
        self.archiveCnt = archiveCnt
        self.validator = validator
        self.findPasswordUsecase = findPasswordUsecase
        self.error = .init()
        self.toastMessage = .init()
    }
    
    enum Action {
        case refreshLoginType
        case moveWithdrawalPage
        case logout
        case getEmail
        case currentPasswordInput(text: String)
        case changeNewPasswordInput(text: String)
        case newPasswordCofirmInput(text: String)
        case changePassword
    }
    
    enum Mutation {
        case setLoginType(LoginType)
        case setEmail(String)
        case empty
        case setChangeNewPassword(String)
        case setEnglishCombination(Bool)
        case setNumberCombination(Bool)
        case setRangeValidation(Bool)
        case setNewPasswordCofirmationInput(String)
        case setCurrentPasswordInput(String)
        case setIsLoading(Bool)
    }
    
    struct State {
        var type: LoginType = .kakao
        var eMail: String = ""
        
        var password: String = ""
        var isValidEmail: Bool = false
        var isEnableSignIn: Bool = false
        var isLoading: Bool = false
    
        var currentPassword: String = ""
        var changePassword: String = ""
        var isContainsEnglish: Bool = false
        var isContainsNumber: Bool = false
        var isWithinRange: Bool = false
        var passwordConfirmationInput: String = ""
        var isSamePasswordInput: Bool {
            if changePassword == "" { return false }
            return changePassword == passwordConfirmationInput
        }
        var isNotNullCurrentPassword: Bool {
            if currentPassword == "" {
                return false
            } else {
                return true
            }
        }
        var isValidPassword: Bool {
            return isContainsEnglish && isContainsNumber && isWithinRange && isSamePasswordInput && isNotNullCurrentPassword
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refreshLoginType:
            let type = self.type
            return .just(.setLoginType(type))
        case .moveWithdrawalPage:
            steps.accept(ArchiveStep.withdrawalIsRequired(self.archiveCnt))
            return .empty()
        case .logout:
            LogInManager.shared.logOut()
            steps.accept(ArchiveStep.logout)
            return .empty()
        case .getEmail:
            return .just(.setEmail(self.email))
        case let .changeNewPasswordInput(text):
            let isContainsEnglish = validator.isContainsEnglish(text)
            let isContainsNumber = validator.isContainsNumber(text)
            let isWithinRage = validator.isWithinRange(text, range: (8...20))
            return .from([.setChangeNewPassword(text),
                          .setEnglishCombination(isContainsEnglish),
                          .setNumberCombination(isContainsNumber),
                          .setRangeValidation(isWithinRage)])
            
        case let .newPasswordCofirmInput(text):
            return .just(.setNewPasswordCofirmationInput(text))
        case .currentPasswordInput(text: let text):
            return .just(.setCurrentPasswordInput(text))
        case .changePassword:
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                changePassword(email: self.email,
                               currentPassword: self.currentState.currentPassword,
                               newPassword: self.currentState.changePassword)
                .map { [weak self] changePasswordResult in
                    switch changePasswordResult {
                    case .success(()):
                        self?.toastMessage.onNext("비밀번호 변경 완료.")
                    case .failure(let err):
                        self?.error.onNext(err.getMessage())
                    }
                    return .empty
                },
                Observable.just(.setIsLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoginType(let type):
            newState.type = type
        case .setEmail(let email):
            newState.eMail = email
        case .empty:
            break
        case .setChangeNewPassword(let newPw):
            newState.changePassword = newPw
        case .setEnglishCombination(let isValidate):
            newState.isContainsEnglish = isValidate
        case .setNumberCombination(let isValidate):
            newState.isContainsNumber = isValidate
        case .setRangeValidation(let isValidate):
            newState.isWithinRange = isValidate
        case .setNewPasswordCofirmationInput(let pw):
            newState.passwordConfirmationInput = pw
        case .setCurrentPasswordInput(let pw):
            newState.currentPassword = pw
        case .setIsLoading(let isLoading):
            newState.isLoading = isLoading
        }
        return newState
    }
    
    // MARK: private function
    
    private func changePassword(email: String, currentPassword: String, newPassword: String) -> Observable<Result<Void, ArchiveError>> {
        return self.findPasswordUsecase.changePassword(eMail: email, currentPassword: currentPassword, newPassword: newPassword)
    }
    
    // MARK: internal function
}
