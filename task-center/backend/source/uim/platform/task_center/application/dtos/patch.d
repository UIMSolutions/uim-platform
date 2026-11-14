/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Optional field of an update request (PATCH semantics: unset = keep).
module uim.platform.task_center.application.dtos.patch;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct Patch(T) {
  private T _value;
  private bool _set;

  this(T value) {
    _value = value;
    _set = true;
  }

  void opAssign(T value) {
    _value = value;
    _set = true;
  }

  bool isSet() const {
    return _set;
  }

  inout(T) value() inout {
    return _value;
  }

  /// Apply to a target if set; returns true if the target changed.
  bool applyTo(ref T target) const {
    if (!_set || target == _value)
      return false;
    target = (() @trusted => cast(T) _value)();
    return true;
  }
}

///
unittest {
  Patch!string p;
  string s = "a";
  assert(!p.applyTo(s) && s == "a");
  p = "b";
  assert(p.isSet && p.applyTo(s) && s == "b");
  assert(!p.applyTo(s));
}
