---
description: Architectural standards, memory management rules, and UI patterns for all Swift files.
applyTo: '**.swift'
---

# Swift Architecture & Coding Standards

When generating or modifying Swift code, strictly adhere to the following principles:

## 1. Concurrency (Swift 6 Strict Concurrency)
- **Prefer modern concurrency:** Always use `async`/`await`, `Task`, and `TaskGroup` over `DispatchQueue`, `OperationQueue`, or completion handlers.
- **Actor isolation:** Use `@MainActor` for any types or functions that update the UI (e.g., ViewModels, UIViewController subclasses). Use custom `actor` types to protect shared mutable state.
- **Sendability:** Ensure custom types passed across asynchronous boundaries conform to the `Sendable` protocol.

## 2. Memory Management
- **Avoid Retain Cycles:** Always capture `[weak self]` in asynchronous closures or delegates where the closure outlives the current scope.
- **Value Semantics:** Default to `struct` and `enum`. Only use `class` when shared reference semantics or Objective-C interoperability (e.g., `@objc`) are strictly required.

## 3. SwiftUI Best Practices
- **State Management:** Use the modern `@Observable` macro (Observation framework) instead of `ObservableObject` and `@Published`.
- **View Composition:** Keep `body` properties under 30 lines. Extract complex layouts into smaller, private computed properties or separate `View` structs.
- **Modifiers:** Chain modifiers logically: apply structural modifiers (frame, padding) before visual modifiers (background, foregroundStyle).

