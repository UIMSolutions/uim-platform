/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The adjustment of a scaling rule: "+1", "-2" (instances) or "+50%",
/// "-25%" (percent of the current instances, at least one instance).
module uim.platform.application_autoscaler.domain.types.adjustment;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

enum int maxAdjustmentInstances = 1000;

struct Adjustment {
  int amount; /// signed: > 0 scale out, < 0 scale in
  bool percent;

  bool scalesOut() const {
    return amount > 0;
  }

  /// The instance count after applying the adjustment (not yet limited).
  int applyTo(int current) const {
    import std.math : ceil;

    if (!percent)
      return current + amount;
    auto delta = cast(int) ceil(current * (amount < 0 ? -amount : amount) / 100.0);
    if (delta < 1)
      delta = 1;
    return amount < 0 ? current - delta : current + delta;
  }

  string toString() const {
    return (amount > 0 ? "+" : "") ~ amount.to!string ~ (percent ? "%" : "");
  }
}

/// Parse "+1", "-2", "+50%". The sign is required. Throws invalid.
Adjustment parseAdjustment(string text) {
  auto t = text.strip.replace(" ", "");
  Adjustment a;
  auto fail = () => AasException.invalid("Adjustment '" ~ text
      ~ "' is invalid (a signed instance count such as +1 or -2, or a percentage such as +50% or -25%)");
  if (t.length < 2 || (t[0] != '+' && t[0] != '-'))
    throw fail();
  a.percent = t[$ - 1] == '%';
  auto digits = a.percent ? t[1 .. $ - 1] : t[1 .. $];
  if (digits.length == 0 || digits.length > 4 || !digits.all!(c => c >= '0' && c <= '9'))
    throw fail();
  auto n = digits.to!int;
  if (n == 0 || n > (a.percent ? 1000 : maxAdjustmentInstances))
    throw fail();
  a.amount = t[0] == '-' ? -n : n;
  return a;
}

///
unittest {
  assert(parseAdjustment("+1").applyTo(2) == 3 && parseAdjustment("-2").applyTo(5) == 3);
  assert(parseAdjustment("+50%").applyTo(4) == 6 && parseAdjustment("+10%").applyTo(2) == 3);
  assert(parseAdjustment("-25%").applyTo(4) == 3 && parseAdjustment("-50%").applyTo(1) == 0);
  assert(parseAdjustment(" +3 ").toString == "+3" && parseAdjustment("-20%").toString == "-20%");
  assert(parseAdjustment("+1").scalesOut && !parseAdjustment("-1").scalesOut);
  foreach (bad; ["1", "+0", "+", "+x", "--1", "+5000", ""])
    assert(failsWith(AasErrorKind.invalid, () { parseAdjustment(bad); }), bad);
}
