/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Value objects shared by several aggregates.
module uim.platform.kyma.domain.types.values;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// An ordered key/value pair (Kubernetes label, annotation, env variable, filter).
struct KeyValue {
  string key;
  string value;
}

/// Value of `key` in a list of pairs ("" if missing).
string valueOf(const KeyValue[] pairs, string key) {
  foreach (p; pairs)
    if (p.key == key)
      return p.value;
  return "";
}

/// Copy of `pairs` with `key` set to `value` (replaced or appended).
KeyValue[] withValue(const KeyValue[] pairs, string key, string value) {
  KeyValue[] result;
  bool replaced;
  foreach (p; pairs) {
    if (p.key == key) {
      result ~= KeyValue(key, value);
      replaced = true;
    } else
      result ~= KeyValue(p.key, p.value);
  }
  if (!replaced)
    result ~= KeyValue(key, value);
  return result;
}

/// One access rule of an API rule: which methods on which path need which strategy.
struct ApiRuleEntry {
  string path = "/*";
  ApiHttpMethod[] methods;
  AccessStrategy accessStrategy = AccessStrategy.noAuth;
  string[] requiredScopes;
  string[] audiences;
  string[] trustedIssuers;
}

/// An API registered by an external application.
struct AppApiEntry {
  string name;
  string description;
  string targetUrl;
  string specUrl;
  string authType = "none";
}

/// An event type published by an external application.
struct AppEventEntry {
  string name;
  string description;
  string version_ = "v1";
}

///
unittest {
  auto pairs = [KeyValue("app", "a")];
  assert(valueOf(pairs, "app") == "a" && valueOf(pairs, "x") == "");
  assert(withValue(pairs, "app", "b") == [KeyValue("app", "b")]);
  assert(withValue(pairs, "tier", "web").length == 2);
}
