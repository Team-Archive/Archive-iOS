//
//  LikeManager.swift
//  Like
//
//  Created by Hanwe LEE on 2022/08/30.
//

import RxSwift
import Foundation

class LikeManager: NSObject {
    
    // MARK: private property
    
    private var willLikeStack: Set<String> = []
    private var willCancelLikeStack: Set<String> = []
    private let usecase: LikeUsecase = LikeUsecase(repository: LikeRepositoryImplement())
    
    private var timer: Timer?
    private let disposeBag = DisposeBag()
    
    // MARK: property
    
    private(set) var likeList: Set<String> = [] {
        didSet {
            print("likeList: \(self.likeList)")
        }
    }
    
    // MARK: lifeCycle
    
    // MARK: private func
    
    @objc func timerIsDone() {
        print("타이머 완료")
        self.timer?.invalidate()
        self.timer = nil
        self.query()
            .subscribe(onNext: { result in
                switch result {
                case .success(_):
                    print("좋아요 쿼리 성공 노티 날려도 됨")
                case .failure(let err):
                    print("err: \(err.localizedDescription)")
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func query() -> Observable<Result<Void, Error>> {
        guard self.willLikeStack.count > 0 || self.willCancelLikeStack.count > 0 else { return .just(.success(())) }
        let copyWillLikeStack = self.willLikeStack
        let copyWillCancelLikeStack = self.willCancelLikeStack
        self.willLikeStack.removeAll()
        self.willCancelLikeStack.removeAll()
        return Observable.merge([
            self.usecase.likeCancel(idList: copyWillLikeStack.map { return $0 }),
            self.usecase.likeCancel(idList: copyWillCancelLikeStack.map { return $0 })
        ])
        .map { result in
            for item in copyWillCancelLikeStack {
                self.likeList.remove(item)
            }
            for item in copyWillLikeStack {
                self.likeList.insert(item)
            }
            switch result {
            case .success(_):
                return .success(())
            case .failure(let err):
                return .failure(err)
            }
        }
    }
    
    // MARK: func
    
    static let shared: LikeManager = {
        let instance = LikeManager()
        return instance
    }()
    
    func like(id: String) {
        self.timer?.invalidate()
        if self.willCancelLikeStack.contains(id) { self.willCancelLikeStack.remove(id) }
        self.willLikeStack.insert(id)
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerIsDone), userInfo: nil, repeats: false)
    }
    
    func likeCancel(id: String) {
        self.timer?.invalidate()
        if self.willLikeStack.contains(id) { self.willLikeStack.remove(id) }
        self.willCancelLikeStack.insert(id)
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerIsDone), userInfo: nil, repeats: false)
    }
    
    func refreshMyLikeList() {
        self.usecase.getMyLikeIdList()
            .subscribe(onNext: { result in
                switch result {
                case .success(let list):
                    self.likeList = list
                case .failure(let err):
                    print("좋아요 리스트 가져오기 오류: \(err.getMessage())")
                }
            })
            .disposed(by: self.disposeBag)
    }
    
}
