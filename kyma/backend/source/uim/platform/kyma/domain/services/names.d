/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.services.names;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// RFC 1123 label: lowercase alphanumerics and "-", starts and ends alphanumeric, ≤ 63 chars.
bool isDnsLabel(string s) pure nothrow {
  if (s.length == 0 || s.length > 63)
    return false;
  foreach (i, c; s) {
    bool alnum = (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9');
    if (!alnum && !(c == '-' && i > 0 && i + 1 < s.length))
      return false;
  }
  return true;
}

/// RFC 1123 subdomain: dot separated labels, ≤ 253 chars ("api.example.com").
bool isDnsName(string s) pure {
  import std.algorithm : all;
  import std.string : split;

  return s.length > 0 && s.length <= 253 && s.split(".").all!(l => isDnsLabel(l));
}

/// Validate the name of a Kubernetes resource of `kind`.
void validateResourceName(string kind, string name) {
  validate(name.length > 0, kind ~ " name is required");
  validate(isDnsLabel(name), kind ~ " name '" ~ name
      ~ "' must be a DNS-1123 label (lowercase letters, digits and '-', max. 63 characters)");
}

/// Names reserved by Kyma itself.
bool isReservedNamespace(string name) pure nothrow {
  return name == "kyma-system" || name == "kube-system" || name == "kube-public"
    || name == "istio-system" || name == "kube-node-lease";
}

///
unittest {
  assert(isDnsLabel("orders-api") && isDnsLabel("a1"));
  assert(!isDnsLabel("Orders") && !isDnsLabel("-x") && !isDnsLabel("x-") && !isDnsLabel(""));
  assert(isDnsName("orders.c-1a2b.kyma.ondemand.com") && !isDnsName("bad..name"));
  assert(isReservedNamespace("kyma-system"));
  bool failed;
  try validateResourceName("Function", "Bad_Name");
  catch (KymaValidationException) failed = true;
  assert(failed);
}
