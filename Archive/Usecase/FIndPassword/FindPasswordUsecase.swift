//
//  FindPasswordUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/04/16.
//

import RxSwift

class FindPasswordUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: FindPasswordRepository
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: FindPasswordRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func sendTempPassword(email: String) -> Observable<Result<Bool, ArchiveError>> {
        return Observable.create { [weak self] emitter in
            self?.repository.isExistEmail(email: email)
                .subscribe(on: ConcurrentDispatchQueueScheduler.init(queue: DispatchQueue.global()))
                .subscribe(onNext: { [weak self] isExistEmailResult in
                    switch isExistEmailResult {
                    case .success(let isExistEmail):
                        if isExistEmail {
                            emitter.onNext(.success(false))
                            emitter.onCompleted()
                        } else {
//                            emitter.onNext(.success(false))
//                            emitter.onCompleted()
                            // 뭔가를 보내자
                        }
                    case .failure(let err):
                        emitter.onNext(.failure(err))
                        emitter.onCompleted()
                    }
                })
                .disposed(by: self?.disposeBag ?? DisposeBag())
            return Disposables.create()
        }
    }
    
}

