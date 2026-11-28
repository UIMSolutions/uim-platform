/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// "key=value" pairs: labels of resource groups, scenarios and artifacts,
/// parameters and input artifact bindings of configurations.
module uim.platform.ai_launchpad.domain.services.labels;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

string labelKey(string pair) pure {
  auto eq = pair.indexOf('=');
  return (eq >= 0 ? pair[0 .. eq] : pair).strip;
}

string labelValue(string pair) pure {
  auto eq = pair.indexOf('=');
  return eq >= 0 ? pair[eq + 1 .. $].strip : "";
}

/// Every entry must be "key=value" with a key of [A-Za-z0-9._/-] (1-128).
void requireLabels(const string[] pairs, string what) {
  if (pairs.length > 100)
    throw AilpException.invalid(format("At most 100 entries of %s are allowed", what.toLower));
  foreach (p; pairs) {
    auto key = labelKey(p);
    auto valid = p.indexOf('=') > 0 && key.length > 0 && key.length <= 128
      && key.all!(c => (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '.' || c == '_'
          || c == '-' || c == '/');
    if (!valid)
      throw AilpException.invalid(what ~ " '" ~ p ~ "' must have the form key=value");
    requireMaxLength(labelValue(p), 1024, what ~ " value");
  }
}

void requireUniqueKeys(const string[] pairs, string what) {
  bool[string] seen;
  foreach (p; pairs) {
    auto key = labelKey(p);
    if (key in seen)
      throw AilpException.invalid("Duplicate " ~ what ~ " '" ~ key ~ "'");
    seen[key] = true;
  }
}

///
unittest {
  assert(labelKey(" epochs = 10") == "epochs" && labelValue("epochs = 10") == "10");
  requireLabels(["ext.ai.sap.com/team=fraud", "a="], "Label");
  assert(failsWith(AilpErrorKind.invalid, () { requireLabels(["novalue"], "Label"); }));
  assert(failsWith(AilpErrorKind.invalid, () { requireLabels(["=x"], "Label"); }));
  assert(failsWith(AilpErrorKind.invalid, () { requireUniqueKeys(["a=1", "a=2"], "parameter"); }));
}
