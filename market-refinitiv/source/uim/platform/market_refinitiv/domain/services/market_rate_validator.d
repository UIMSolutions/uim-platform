/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.domain.services.market_rate_validator;
import uim.platform.market_refinitiv;

mixin(ShowModule!());

@safe:

// Domain validation rules for market rate records
struct MarketRateValidator {

  // Combined key1 + key2 must not exceed 15 characters (S/4HANA download constraint)
  static string validateKeys(string key1, string key2) {
    if (key1.length == 0)
      return "key1 is required";
    if ((key1.length + key2.length) > 15)
      return "Combined key1 and key2 must not exceed 15 characters";
    // Reserved characters
    foreach (ch; key1 ~ key2) {
      if (ch == '~' || ch == ':')
        return "Keys must not contain reserved characters ~ or :";
    }
    return "";
  }

  static string validateDate(string date) {
    if (date.length != 8)
      return "Date must be in YYYYMMDD format (8 characters)";
    return "";
  }

  static string validateTime(string time) {
    if (time.length != 6)
      return "Time must be in HHMMSS format (6 characters)";
    return "";
  }

  static string validateRate(MarketRate r) {
    auto err = validateKeys(r.key1, r.key2);
    if (err.length > 0) return err;

    err = validateDate(r.effectiveDate);
    if (err.length > 0) return err;

    err = validateTime(r.effectiveTime);
    if (err.length > 0) return err;

    if (r.providerCode.length == 0)
      return "providerCode is required";

    return "";
  }
}
