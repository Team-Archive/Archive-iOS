//
//  MyLikeRepositoryStub.swift
//  Archive
//
//  Created by hanwe on 2022/07/31.
//

import RxSwift

class MyLikeRepositoryStub: MyLikeRepository {
    func getMyLikeArchives() -> Observable<Result<[MyLikeArchive], ArchiveError>> {
        return .just(.success([
            MyLikeArchive(authorId: 86,
                          mainImage: "https://archive-depromeet-images-dev.s3.ap-northeast-2.amazonaws.com/webp/images/da51e2b4-0dd5-41b3-bf6c-d230613f8ed1-2022-07-23-20%3A23%3A41.webp",
                          authorProfileImage: "",
                          archiveName: "2222",
                          isLiked: true,
                          archiveId: 50,
                          authorNickname: "",
                          emotion: .fresh,
                          watchedOn: "22/07/23",
                          dateMilli: 1658543021000,
                          likeCount: 1),
            MyLikeArchive(authorId: 86,
                          mainImage: "https://archive-depromeet-images-dev.s3.ap-northeast-2.amazonaws.com/webp/images/4bd306d6-76c5-43ee-902a-53ed60822a36-2022-07-23-20%3A23%3A23.webp",
                          authorProfileImage: "",
                          archiveName: "111",
                          isLiked: true,
                          archiveId: 49,
                          authorNickname: "",
                          emotion: .fresh,
                          watchedOn: "22/07/23",
                          dateMilli: 1658543004000,
                          likeCount: 1)
        ]))
    }
}
