//
//  MyPageReactor.swift
//  Archive
//
//  Created by hanwe on 2021/10/21.
//

import ReactorKit
import RxSwift
import RxRelay
import RxFlow
import SwiftyJSON

class MyPageReactor: Reactor, Stepper, MainTabStepperProtocol {
    
    // MARK: private property
    
    // MARK: internal property
    
    let steps = PublishRelay<Step>()
    let initialState: State
    
    // MARK: lifeCycle
    
    init() {
        self.initialState = .init()
    }
    
    enum Action {
        case endFlow
        case moveToLoginInfo
        case openTerms
        case openPrivacy
    }
    
    enum Mutation {
        case empty
        case setIsLoading(Bool)
    }
    
    struct State {
        let cardCnt: Int = 0
        var isLoading: Bool = false
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .endFlow:
            self.steps.accept(ArchiveStep.myPageIsComplete)
            return .empty()
        case .moveToLoginInfo:
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                self.getMyUserInfo().map { [weak self] result in
                    switch result {
                    case .success(let data):
                        if let jsonData: JSON = try? JSON.init(data: data) {
                            let mailAddrStr = jsonData["mailAddress"].stringValue
                            self?.steps.accept(ArchiveStep.loginInfomationIsRequired(LogInManager.shared.logInType, mailAddrStr, self?.currentState.cardCnt ?? 0))
                        }
                    case .failure(let err):
                        print("err: \(err.localizedDescription)")
                    }
                    return .setIsLoading(false)
                }
            ])
        case .openTerms:
            guard let url = URL(string: "https://wise-icicle-d10.notion.site/8ad4c5884b814ff6a6330f1a6143c1e6") else { return .empty()}
            self.steps.accept(ArchiveStep.openUrlIsRequired(url: url, title: "이용약관"))
            return .empty()
        case .openPrivacy:
            guard let url = URL(string: "https://wise-icicle-d10.notion.site/13ff403ad4e2402ca657fb20be31e4ae") else { return .empty()}
            self.steps.accept(ArchiveStep.openUrlIsRequired(url: url, title: "개인정보 처리방침"))
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .empty:
            break
        case .setIsLoading(let isLoading):
            newState.isLoading = isLoading
        }
        return newState
    }
    
    // MARK: private function
    
    private func getMyUserInfo() -> Observable<Result<Data, Error>> {
        let provider = ArchiveProvider.shared.provider
        
        return provider.rx.request(.getCurrentUserInfo, callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                return .success(result.data)
            }
            .catch { err in
                .just(.failure(err))
            }
    }
    
    // MARK: internal function
    
    func runReturnEndFlow() {
        self.action.onNext(.endFlow)
    }
    
}
