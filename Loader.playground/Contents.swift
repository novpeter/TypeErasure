import Foundation

enum Result<T> {
    case success([T])
    case failure
}

/// Протокол с типом
protocol Loader {
    associatedtype DataType
    
    func load(completion: @escaping (Result<DataType>) -> Void)
}

/// Приватный абстрактный класс
private class _AnyLoaderBox<DataType>: Loader {
    func load(completion: @escaping (Result<DataType>) -> Void) {
        fatalError("Calling method of abstract class!")
    }
}

/// Приватный класс обертка
private class _LoaderBox<Base: Loader>: _AnyLoaderBox<Base.DataType> {
    
    private let _base: Base
    
    init(_ base: Base) {
        _base = base
    }
    
    override func load(completion: @escaping (Result<Base.DataType>) -> Void) {
        _base.load(completion: completion)
    }
}

/// Финальный лоадер
final class AnyLoader<DataType>: Loader {
    
    private let _loader: _AnyLoaderBox<DataType>
    
    init<LoaderType: Loader>(_ loader: LoaderType) where LoaderType.DataType == DataType {
        _loader = _LoaderBox(loader)
    }
    
    func load(completion: @escaping (Result<DataType>) -> Void) {
        _loader.load(completion: completion)
    }
}


// MARK: - Example

class SongLoader: Loader {
    struct Song {
        let title: String
        let singer: String
    }
    
    typealias DataType = Song
    
    let songs = [Song(title: "title1", singer: "Singer1"),
                    Song(title: "title2", singer: "Singer2"),
                    Song(title: "title3", singer: "Singer3")]
    
    func load(completion: @escaping (Result<Song>) -> Void) {
        completion(.success(songs))
    }
}


let songLoader = SongLoader()

let loaders = [AnyLoader(songLoader)]

loaders.map { $0.load { (result) in
    if case let .success(data) = result { print(data) }
    }
}
