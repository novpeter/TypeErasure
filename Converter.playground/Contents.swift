import Foundation

protocol ObjectConverter {
    associatedtype SourceType
    associatedtype ResultType
    
    func convert(_ object: SourceType) -> ResultType
}

/// Приватный абстрактный класс
private class _AnyConverterBox<SourceType, ResultType>: ObjectConverter {
    
    func convert(_ object: SourceType) -> ResultType {
        fatalError("This is abstract method!")
    }
}

/// Приватный класс обертка
private class _ConverterBox<Base: ObjectConverter>: _AnyConverterBox<Base.SourceType, Base.ResultType> {
    private let _base: Base
    
    init(_ base: Base) {
        _base = base
    }
    
    override func convert(_ object: Base.SourceType) -> Base.ResultType {
        return _base.convert(object)
    }
}

/// Финальный конвертер
final class AnyObjectConverter<SourceType, ResultType>: ObjectConverter {
    
    /// Оббертка
    private let _box: _AnyConverterBox<SourceType, ResultType>
    
    init<ConvertType: ObjectConverter>(_ convertType: ConvertType)
       where ConvertType.SourceType == SourceType,
             ConvertType.ResultType == ResultType {
       
       _box = _ConverterBox(convertType)
    }
    
    func convert(_ object: SourceType) -> ResultType {
       return _box.convert(object)
    }
}

/// Статья
struct Article { }

/// Сервис по работе со статьями
class ArticleService {
    
    /// Конвертит статью в строку
    var converter: AnyObjectConverter<Article, String>!
}
