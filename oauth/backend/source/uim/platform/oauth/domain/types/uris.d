/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Redirect URI and URL rules (RFC 6749 §3.1.2, OAuth 2.0 Security BCP).
module uim.platform.oauth.domain.types.uris;

import std.ascii : isAlphaNum;
import std.string : indexOfAny;
import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// True for http:// and https:// URLs with a host.
bool isHttpUrl(string url) pure {
  foreach (scheme; ["http://", "https://"])
    if (url.startsWith(scheme) && url.length > scheme.length && url[scheme.length] != '/')
      return true;
  return false;
}

/// Host part of an http(s) URL ("" if none).
string hostOf(string url) pure {
  auto rest = url.startsWith("https://") ? url[8 .. $] : url.startsWith("http://") ? url[7 .. $] : "";
  auto end = rest.indexOfAny("/?#");
  auto authority = end >= 0 ? rest[0 .. end] : rest;
  auto at = authority.lastIndexOf('@');
  if (at >= 0)
    authority = authority[at + 1 .. $];
  if (authority.startsWith("[")) {
    auto close = authority.indexOf(']');
    return close > 0 ? authority[0 .. close + 1] : authority;
  }
  auto colon = authority.lastIndexOf(':');
  return colon >= 0 ? authority[0 .. colon] : authority;
}

/// True for loopback hosts (plain http is allowed only for them).
bool isLoopbackHost(string host) pure {
  return host == "localhost" || host == "127.0.0.1" || host == "[::1]";
}

/// Validation message for a redirect URI ("" = valid).
///   * absolute, no fragment, no wildcard (exact matching only)
///   * https, http only for loopback, or a private-use scheme (com.example.app:/cb) for native apps
string redirectUriProblem(string uri) pure {
  if (uri.length == 0)
    return "Redirect URI must not be empty";
  if (uri.length > 2048)
    return "Redirect URI is too long";
  if (uri.canFind('#'))
    return "Redirect URI '" ~ uri ~ "' must not contain a fragment";
  if (uri.canFind('*'))
    return "Redirect URI '" ~ uri ~ "' must not contain wildcards (exact match only)";
  if (uri.canFind(' '))
    return "Redirect URI '" ~ uri ~ "' must not contain spaces";
  if (uri.startsWith("https://"))
    return isHttpUrl(uri) ? "" : "Redirect URI '" ~ uri ~ "' has no host";
  if (uri.startsWith("http://"))
    return isHttpUrl(uri) && isLoopbackHost(hostOf(uri)) ? ""
      : "Redirect URI '" ~ uri ~ "' must use https (http is allowed for localhost only)";
  auto colon = uri.indexOf(':');
  if (colon > 0 && uri[0 .. colon].canFind('.') && uri[0 .. colon].all!(c => isAlphaNum(c) || c == '.' || c == '-' || c == '+'))
    return ""; // private-use URI scheme (RFC 8252 §7.1)
  return "Redirect URI '" ~ uri ~ "' must be an absolute https URI";
}

///
unittest {
  assert(isHttpUrl("https://x.example.com/a") && !isHttpUrl("ftp://x") && !isHttpUrl("http:///x"));
  assert(hostOf("https://user@app.example.com:8443/cb?x") == "app.example.com");
  assert(hostOf("http://[::1]:8080/cb") == "[::1]");
  assert(redirectUriProblem("https://app.example.com/callback") == "");
  assert(redirectUriProblem("http://localhost:5000/callback") == "");
  assert(redirectUriProblem("com.example.app:/oauth2redirect") == "");
  assert(redirectUriProblem("http://app.example.com/cb").length > 0);
  assert(redirectUriProblem("https://app.example.com/cb#x").length > 0);
  assert(redirectUriProblem("https://*.example.com/cb").length > 0);
  assert(redirectUriProblem("/relative").length > 0);
}
