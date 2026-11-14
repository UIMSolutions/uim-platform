/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Pure validation rules shared by the entities.
module uim.platform.service_manager.domain.services.validation;

import std.ascii : isAlphaNum, isControl;
import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

enum size_t maxResourceNameLength = 255;

/// Names are 1..255 characters without control characters and without
/// leading / trailing blanks.
bool isValidResourceName(string name) {
  if (name.length == 0 || name.length > maxResourceNameLength || name.strip != name)
    return false;
  foreach (char c; name)
    if (isControl(c))
      return false;
  return true;
}

/// Throw invalid if the name is missing or malformed.
void requireName(string name, string what) {
  if (name.strip.length == 0)
    throw ServiceManagerException.invalid(what ~ " name is required");
  if (!isValidResourceName(name))
    throw ServiceManagerException.invalid(what ~ " name must be 1-255 characters without control characters or surrounding blanks");
}

/// http:// or https:// with a host.
bool isHttpUrl(string url) {
  auto u = url.strip;
  foreach (scheme; ["http://", "https://"])
    if (u.length > scheme.length && u[0 .. scheme.length].toLower == scheme)
      return !u[scheme.length .. $].startsWith("/");
  return false;
}

/// Label keys: 1..63 of [A-Za-z0-9._/-], starting with a letter or digit.
bool isValidLabelKey(string key) {
  if (key.length == 0 || key.length > 63 || !isAlphaNum(key[0]))
    return false;
  foreach (char c; key)
    if (!isAlphaNum(c) && c != '.' && c != '_' && c != '-' && c != '/')
      return false;
  return true;
}

/// Empty or valid JSON text.
bool isJsonText(string text) @trusted {
  if (text.strip.length == 0)
    return true;
  try {
    parseJsonString(text);
    return true;
  } catch (Exception)
    return false;
}

void requireJsonText(string text, string field) {
  if (!isJsonText(text))
    throw ServiceManagerException.invalid("'" ~ field ~ "' must be valid JSON");
}

///
unittest {
  assert(isValidResourceName("my-hana"));
  assert(!isValidResourceName(" padded"));
  assert(!isValidResourceName("tab\there"));
  assert(isHttpUrl("https://broker.example.com/osb"));
  assert(isHttpUrl("HTTP://localhost:9000"));
  assert(!isHttpUrl("https://"));
  assert(!isHttpUrl("broker.example.com"));
  assert(isValidLabelKey("env") && isValidLabelKey("app.kubernetes.io/name"));
  assert(!isValidLabelKey("-x") && !isValidLabelKey("has space"));
  assert(isJsonText("") && isJsonText(`{"a":1}`) && !isJsonText("{oops"));
}
