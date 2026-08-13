---
name: dlang-vibe-code
description: "Use when implementing, debugging, reviewing, or testing D code with vibe.d in the uim-platform repository, especially service packages, HTTP controllers, URLRouter routes, JSON handlers, repositories, use cases, and manual DI."
---

# D and vibe.d Service Workflow

Use this skill for changes in this repository's D microservices. Keep the change inside the owning service unless a shared `service/` contract must change.

## 1. Locate the owning path

1. Identify the service directory and read its `dub.sdl`, entry point, and the nearest implementation or test.
2. Follow the repository's four layers:
   - `domain/`: entities, value types, ports, and business services.
   - `application/`: DTOs and use cases.
   - `presentation/`: HTTP controllers and JSON/view models.
   - `infrastructure/`: configuration, manual DI, persistence, and adapters.
3. If the starting file only forwards or registers behavior, step to the nearest code that computes or mutates it.
4. State one falsifiable local hypothesis about the behavior and one cheap check that could disconfirm it before editing.

## 2. Choose the smallest matching change

- Business rules belong in domain services or use cases, not controllers.
- Repository contracts belong in domain ports; implementations belong under infrastructure persistence.
- Add request and command-result shapes to the service's existing DTO conventions.
- Wire new repositories, use cases, and controllers in `infrastructure/container.d` in that order, then register routes from `app.d` or the owning controller.
- Preserve existing controller response helpers and status conventions.
- Prefer the repository's established naming: snake_case modules, PascalCase types, `{Entity}Id` aliases, `*Repository` interfaces, `Memory*Repository` implementations, `*UseCase` use cases, and `*Controller` controllers.

## 3. Implement vibe.d HTTP behavior carefully

- Use `HTTPServerRequest` and `HTTPServerResponse` with the existing `SAPController` or service base controller.
- Register DELETE routes with `router.delete_`, not `del`.
- Use a trailing wildcard such as `/api/v1/items/*` for an ID route. Parse the ID from `req.requestPath.to!string`; URLRouter does not provide a three-argument `(req, res, id)` handler.
- Wildcards may only occur at the end of a route pattern.
- Read JSON from `req.json`; `HTTPServerRequest` has no `readJson()` method in the repository's vibe-http version.
- Return JSON through the existing `writeJsonBody`, `successResponse`, and `writeError` helpers. Cast HTTP status values to `int` when calling low-level `writeBody`.
- Keep tenant or path precheck context. For derived list handlers that need it, call `super.getHandler(req)` rather than a generic list handler that discards the context.

## 4. Handle D and JSON APIs defensively

- Import `std.conv : to` before using `.to!string` for enum or string conversion.
- Avoid reserved identifiers such as `deprecated`, `version`, `ref`, and `out` for variables, parameters, or enum members.
- Do not assume `Json` has chainable `.set` or supports direct string-array construction. Build objects with `j["key"] = Json(value)` and arrays with `Json.emptyArray` plus element assignment when needed.
- For optional JSON fields, check key presence before calling `.get!T`; do not rely on unsupported default overloads.
- `req.query` is a `DictionaryList`; iterate with `byKeyValue()` when iteration is required.
- Do not append `const(S)` directly to mutable arrays when pointers or associative arrays are involved; copy or construct a mutable value.
- Treat `.init` on classes as null. Null-check before dereferencing sentinel objects.
- Keep code `@safe` where the surrounding module uses it and avoid one-letter names.

## 5. Validate in a narrow loop

After each substantive edit, run the cheapest check for the touched slice first:

1. Compile or test the owning package: `cd <service> && dub test`.
2. If the change affects executable wiring, also run `dub build --build=release --config=defaultRun` in that service.
3. For shared service changes, run the service package check and then the workspace root `dub test`.
4. Re-run the same focused command after each local repair before widening scope.
5. Inspect the built endpoint or neighboring integration test when the change is HTTP-visible.

When a compile error is confusing, verify the controlling type and import first. Common misleading failures include UFCS resolving a missing field as a function call, missing `std.conv : to`, duplicate module names causing `__ModuleInfo` linker errors, and callback `nothrow` requirements around `runTask`.

## Completion criteria

A change is complete only when:

- The behavior is implemented at the owning architectural layer.
- New dependencies are wired through the manual container and routes are registered.
- Tenant scoping, ID extraction, JSON defaults, status codes, and error paths are preserved.
- The owning package's focused `dub test` or build passes.
- Shared changes have also been checked from the workspace root.
- No unrelated files or generated build artifacts were modified.
