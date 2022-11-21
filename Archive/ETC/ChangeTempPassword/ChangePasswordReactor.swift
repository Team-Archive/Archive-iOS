//
//  ChangePasswordReactor.swift
//  Archive
//
//  Created by hanwe on 2022/11/21.
//

import ReactorKit
import SwiftyJSON
import Moya
import Foundation

final class ChangePasswordReactor: Reactor {
    
    // MARK: private property
    
    private let findPasswordUsecase: FindPasswordUsecase
    private let validator: Validator
    private let email: String
    
    // MARK: internal property
    
    let initialState: State = State()
    let err: PublishSubject<ArchiveError> = .init()
    let toastMessage: PublishSubject<String> = .init()
    let changePasswordComplete: PublishSubject<Void> = .init()
    
    // MARK: lifeCycle
    
    init(findPasswordRepository: FindPasswordRepository, validator: Validator, email: String) {
        self.findPasswordUsecase = FindPasswordUsecase(repository: findPasswordRepository)
        self.validator = validator
        self.email = email
    }
    
    enum Action {
        case changepasswordInput(text: String)
        case passwordCofirmInput(text: String)
        case tempPasswordInput(text: String)
        case changePassword
    }
    
    enum Mutation {
        case empty
        case setIsLoading(Bool)
        
        case setChangePassword(String)
        case setEnglishCombination(Bool)
        case setNumberCombination(Bool)
        case setRangeValidation(Bool)
        case setPasswordCofirmationInput(String)
        case setTempPasswordInput(String)
    }
    
    struct State {
        var isLoading: Bool = false
        
        var tempPassword: String = ""
        var changePassword: String = ""
        var isContainsEnglish: Bool = false
        var isContainsNumber: Bool = false
        var isWithinRange: Bool = false
        var passwordConfirmationInput: String = ""
        var isSamePasswordInput: Bool {
            if changePassword == "" { return false }
            return changePassword == passwordConfirmationInput
        }
        var isNotNullTempPassword: Bool {
            if tempPassword == "" {
                return false
            } else {
                return true
            }
        }
        var isValidPassword: Bool {
            return isContainsEnglish && isContainsNumber && isWithinRange && isSamePasswordInput && isNotNullTempPassword
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .changepasswordInput(text):
            let isContainsEnglish = validator.isContainsEnglish(text)
            let isContainsNumber = validator.isContainsNumber(text)
            let isWithinRage = validator.isWithinRange(text, range: (8...20))
            return .from([.setChangePassword(text),
                          .setEnglishCombination(isContainsEnglish),
                          .setNumberCombination(isContainsNumber),
                          .setRangeValidation(isWithinRage)])
            
        case let .passwordCofirmInput(text):
            return .just(.setPasswordCofirmationInput(text))
        case .tempPasswordInput(text: let text):
            return .just(.setTempPasswordInput(text))
        case .changePassword:
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                changePassword(email: self.email,
                               tempPassword: self.currentState.tempPassword,
                               newPassword: self.currentState.changePassword)
                .map { [weak self] changePasswordResult in
                    switch changePasswordResult {
                    case .success(()):
                        self?.toastMessage.onNext("비밀번호 변경 완료")
                        self?.changePasswordComplete.onNext(())
                    case .failure(let err):
                        self?.err.onNext(err)
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
        case .empty:
            break
        case .setIsLoading(let isLoading):
            newState.isLoading = isLoading
            return newState
        case let .setChangePassword(password):
            newState.changePassword = password
        case let .setEnglishCombination(isContainsEnglish):
            newState.isContainsEnglish = isContainsEnglish
        case let.setNumberCombination(isContainsNumber):
            newState.isContainsNumber = isContainsNumber
        case let .setRangeValidation(isWithinRange):
            newState.isWithinRange = isWithinRange
        case let .setPasswordCofirmationInput(password):
            newState.passwordConfirmationInput = password
        case .setTempPasswordInput(let password):
            newState.tempPassword = password
        }
        return newState
    }
    
    // MARK: private function
    
    private func changePassword(email: String, tempPassword: String, newPassword: String) -> Observable<Result<Void, ArchiveError>> {
        return self.findPasswordUsecase.changePassword(eMail: email, currentPassword: tempPassword, newPassword: newPassword)
    }
    
    // MARK: internal function
    
}
