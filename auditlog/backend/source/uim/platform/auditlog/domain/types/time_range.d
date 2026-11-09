/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.types.time_range;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Value object: a closed time interval in stdTime (hnsecs).
/// A bound of 0 means "open" on that side.
struct TimeRange {
  long from;
  long to;

  /// True if the timestamp lies inside the range (open bounds always match).
  bool contains(long timestamp) const pure nothrow @nogc {
    if (from > 0 && timestamp < from)
      return false;
    if (to > 0 && timestamp > to)
      return false;
    return true;
  }

  /// True if neither bound is set.
  bool isOpen() const pure nothrow @nogc {
    return from <= 0 && to <= 0;
  }

  /// True if both bounds are set and from > to.
  bool isInverted() const pure nothrow @nogc {
    return from > 0 && to > 0 && from > to;
  }
}
///
unittest {
  mixin(ShowTest!("TimeRange"));

  auto open = TimeRange();
  assert(open.isOpen);
  assert(open.contains(42));

  auto r = TimeRange(10, 20);
  assert(!r.isOpen);
  assert(r.contains(10) && r.contains(20) && r.contains(15));
  assert(!r.contains(9) && !r.contains(21));
  assert(TimeRange(30, 20).isInverted);
}
