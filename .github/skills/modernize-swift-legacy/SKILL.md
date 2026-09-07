---
name: modernize-swift-legacy
description: 'Upgrades legacy Swift code by replacing completion handlers with async/await and updating Combine to the Observation framework.'
---

# Modernize Swift Legacy Code

When invoked to modernize Swift syntax on a specific file or directory, apply the following transformations step-by-step:

1. **Concurrency Migration:**
   - Locate functions using `@escaping` closures for success/failure callbacks.
   - Rewrite the signature to use `async throws`.
   - Replace internal `completion(.success(data))` calls with `return data`.
   - Replace `completion(.failure(error))` calls with `throw error`.

2. **State Management (Observation):**
   - Find classes conforming to `ObservableObject`.
   - Remove the `@Published` property wrappers.
   - Add the `@Observable` macro above the class declaration.

3. **Thread Safety:**
   - Ensure that any class responsible for driving UI updates is annotated with `@MainActor`.
