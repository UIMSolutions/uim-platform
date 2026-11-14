/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Branding value rules.
module uim.platform.oauth.domain.types.colors;

import std.ascii : isHexDigit;
import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// "#RGB" or "#RRGGBB" (empty = not set).
bool isBrandingColor(string value) pure {
  return (value.length == 4 || value.length == 7) && value[0] == '#' && value[1 .. $].all!(c => isHexDigit(c));
}

/// Validation message for custom CSS ("" = acceptable). The CSS is embedded
/// into the login page, so constructs that can escape the style element or
/// execute script are rejected.
string customCssProblem(string css) pure {
  enum size_t maxLength = 16 * 1024;
  if (css.length > maxLength)
    return format("Custom CSS must not exceed %d characters", maxLength);
  auto lower = css.toLower;
  foreach (forbidden; ["</style", "<script", "javascript:", "expression(", "@import", "behavior:", "-moz-binding"])
    if (lower.canFind(forbidden))
      return "Custom CSS must not contain '" ~ forbidden ~ "'";
  return "";
}

///
unittest {
  assert(isBrandingColor("#0a6ed1") && isBrandingColor("#FFF") && !isBrandingColor("0a6ed1") && !isBrandingColor("#12345G"));
  assert(customCssProblem(".logo { height: 48px; }") == "");
  assert(customCssProblem("</style><script>alert(1)</script>").length > 0);
  assert(customCssProblem("a { background: url(javascript:x) }").length > 0);
}
