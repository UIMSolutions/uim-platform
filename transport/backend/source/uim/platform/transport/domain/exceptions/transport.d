/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.exceptions.transport;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Business exception with an HTTP-like status code
/// (400 invalid input, 404 not found, 409 conflict, 422 business rule violated).
class TransportException : Exception {
  int code;

  this(int code, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.code = code;
  }
}
