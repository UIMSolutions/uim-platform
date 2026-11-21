/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Partial updates (PATCH semantics): the new values plus the names of
/// the members that were sent. Members not listed keep their value.
module uim.platform.data_quality.application.dtos.changes;

import std.traits : FieldNameTuple;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct Changes(T) {
  T values;
  string[] fields;

  bool has(string field) const {
    return fields.canFind(field);
  }

  /// Mark a member as sent.
  ref Changes set(string field) return {
    if (!has(field))
      fields ~= field;
    return this;
  }

  /// Copy the sent members onto target; unknown names are ignored.
  void applyTo(ref T target) const @trusted {
    static foreach (name; FieldNameTuple!T)
      if (has(name))
        __traits(getMember, target, name) = cast(typeof(__traits(getMember, target, name))) __traits(getMember, values, name);
  }
}

///
unittest {
  struct S {
    string a = "a";
    int b = 1;
    string[] c;
  }

  Changes!S ch;
  ch.values.b = 7;
  ch.values.a = "x";
  ch.set("b");
  S s;
  ch.applyTo(s);
  assert(s.a == "a" && s.b == 7);
}
