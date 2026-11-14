/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.exceptions.translation;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Base class of all business exceptions of the translation domain.
/// `status` is the HTTP-like status a driving adapter should report.
class TranslationException : Exception {
  int status;

  this(string msg, int status = 400, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.status = status;
  }
}

/// Input violates a business rule (unsupported language, empty text, text too long, ...).
class TranslationValidationException : TranslationException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, 422, file, line);
  }
}

/// A referenced aggregate does not exist.
class TranslationNotFoundException : TranslationException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, 404, file, line);
  }
}

/// The operation conflicts with the current state (duplicate, archived project, finished job, ...).
class TranslationConflictException : TranslationException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, 409, file, line);
  }
}

/// Throw a validation exception unless `condition` holds.
void validate(bool condition, lazy string message) {
  if (!condition)
    throw new TranslationValidationException(message);
}

/// Throw a conflict exception unless `condition` holds.
void ensureState(bool condition, lazy string message) {
  if (!condition)
    throw new TranslationConflictException(message);
}
