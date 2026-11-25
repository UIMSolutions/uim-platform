/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validation of extracted / corrected values by their type. Values are
/// exchanged as text: numbers with '.' as decimal separator, dates ISO 8601
/// (YYYY-MM-DD), booleans true/false, currencies ISO 4217 (3 letters).
module uim.platform.document_ai.domain.services.field_values;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

/// Throws invalid if the (non-empty) value does not match the type.
void checkFieldValue(FieldValueType type, string value, string what = "Value") @trusted {
  import std.ascii : isUpper;

  auto v = value.strip;
  requireMaxLength(v, 4000, what);
  final switch (type) {
  case FieldValueType.text, FieldValueType.address:
    return;
  case FieldValueType.number:
    try {
      v.to!double;
      return;
    } catch (Exception) {
      throw DaiException.invalid(what ~ " '" ~ value ~ "' is not a number (use '.' as decimal separator)");
    }
  case FieldValueType.date:
    try {
      Date.fromISOExtString(v);
      return;
    } catch (Exception) {
      throw DaiException.invalid(what ~ " '" ~ value ~ "' is not an ISO date (YYYY-MM-DD)");
    }
  case FieldValueType.boolean:
    if (v == "true" || v == "false")
      return;
    throw DaiException.invalid(what ~ " '" ~ value ~ "' must be true or false");
  case FieldValueType.currency:
    if (v.length == 3 && v.all!(c => isUpper(c)))
      return;
    throw DaiException.invalid(what ~ " '" ~ value ~ "' is not an ISO 4217 currency code (e.g. EUR)");
  }
}

///
unittest {
  checkFieldValue(FieldValueType.number, "-12.5");
  checkFieldValue(FieldValueType.date, "2026-11-25");
  checkFieldValue(FieldValueType.currency, "EUR");
  checkFieldValue(FieldValueType.boolean, "false");
  checkFieldValue(FieldValueType.text, "anything");
  assert(failsWith(DaiErrorKind.invalid, () { checkFieldValue(FieldValueType.number, "1,5"); }));
  assert(failsWith(DaiErrorKind.invalid, () { checkFieldValue(FieldValueType.date, "25.11.2026"); }));
  assert(failsWith(DaiErrorKind.invalid, () { checkFieldValue(FieldValueType.currency, "eur"); }));
}
