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
    
    private let usecase: MyPageUsecase
    private let myLikeUsecase: MyLikeUsecase
    
    // MARK: internal property
    
    let steps = PublishRelay<Step>()
    let initialState: State
    let err: PublishSubject<ArchiveError> = .init()
    
    // MARK: lifeCycle
    
    init(repository: MyPageRepository, myLikeRepository: MyLikeRepository) {
        self.initialState = .init()
        self.usecase = MyPageUsecase(repository: repository)
        self.myLikeUsecase = MyLikeUsecase(repository: myLikeRepository)
    }
    
    enum Action {
        case endFlow
        case moveToLoginInfo
        case openTerms
        case openPrivacy
        case moveToLikeList
    }
    
    enum Mutation {
        case empty
        case setIsLoading(Bool)
    }
    
    struct State {
        let cardCnt: Int = 0 // TODO: 아카이브 갯수만 받아오는 API추가해야할듯
        var isLoading: Bool = false
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .endFlow:
            self.steps.accept(ArchiveStep.myPageIsComplete)
            return .empty()
        case .moveToLikeList:
            self.steps.accept(ArchiveStep.myLikeListIsRequired(reactor: self))
            return .empty()
        case .moveToLoginInfo:
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                self.getCurrentUserInfo().map { [weak self] result in
                    switch result {
                    case .success(let info):
                        self?.steps.accept(ArchiveStep.loginInfomationIsRequired(stepper: self?.steps ?? .init(),
                                                                                 info: info,
                                                                                 archiveCnt: self?.currentState.cardCnt ?? 0))
                    case .failure(let err):
                        self?.err.onNext(err)
                    }
                    return .empty
                },
                Observable.just(.setIsLoading(false))
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
    
    private func getCurrentUserInfo() -> Observable<Result<MyLoginInfo, ArchiveError>> {
        return self.usecase.getCurrentUserInfo()
    }
    
    
    // MARK: internal function
    
    func runReturnEndFlow() {
        self.action.onNext(.endFlow)
    }
    
}
