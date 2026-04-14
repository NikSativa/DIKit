import Foundation

/// Overrides the string key a `Container` uses when registering or resolving
/// a type.
///
/// By default the container derives keys from the type's runtime metadata
/// via `ObjectIdentifier`. Types conforming to `ContainerKeyProviding`
/// supply their own key instead — useful for pinning a stable key across
/// builds, aliasing types, or bridging types whose metatype cannot be
/// reflected reliably.
///
/// The key is used for both registration and resolution, so every
/// registration site for a given type must produce the same key.
public protocol ContainerKeyProviding {
    /// Stable key identifying this type inside a `Container`.
    static var containerKey: String { get }
}
