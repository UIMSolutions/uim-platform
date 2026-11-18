/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// CORS preflight evaluation and rule validation.
module uim.platform.object_store.domain.services.cors_matcher;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Normalized origin pattern ("https://app.example.com", "https://*.example.com", "*").
string normalizeOrigin(string origin) pure {
  return origin.strip.toLower.stripRight("/");
}

/// Validate a CORS rule (422 on violation) and normalize its lists.
void validateCorsRule(ref CorsRule rule) {
  rule.allowedOrigins = rule.allowedOrigins.map!(o => normalizeOrigin(o)).filter!(o => o.length > 0).array;
  validate(rule.allowedOrigins.length > 0, "CORS rule '" ~ rule.name ~ "' needs at least one allowed origin");
  foreach (o; rule.allowedOrigins)
    validate(o == "*" || o.startsWith("http://") || o.startsWith("https://"),
      "Allowed origins must be '*' or start with http:// or https:// (got '" ~ o ~ "')");
  validate(rule.allowedMethods.length > 0, "CORS rule '" ~ rule.name ~ "' needs at least one allowed method");
  validate(rule.maxAgeSeconds >= 0 && rule.maxAgeSeconds <= 86_400, "maxAgeSeconds must be between 0 and 86400");
}

/// Evaluate a browser request against the CORS rules of a bucket. The first
/// rule that allows origin, method and every requested header wins.
CorsDecision matchCors(const CorsRule[] rules, string origin, CorsMethod method, const string[] requestHeaders) {
  CorsDecision d;
  d.origin = normalizeOrigin(origin);
  foreach (ref r; rules) {
    if (!r.allowedOrigins.any!(o => o == "*" || wildcardMatch(d.origin, o)))
      continue;
    if (!r.allowedMethods.canFind(method))
      continue;
    bool headersOk = requestHeaders.all!(h => r.allowedHeaders.canFind("*")
        || r.allowedHeaders.any!(a => a.toLower == h.strip.toLower));
    if (!headersOk)
      continue;
    d.allowed = true;
    d.matchedRule = r.name;
    d.allowOrigin = r.allowedOrigins.canFind("*") ? "*" : d.origin;
    d.allowMethods = r.allowedMethods.map!(m => enumText(m).toUpper).array;
    d.allowHeaders = r.allowedHeaders.dup;
    d.exposeHeaders = r.exposedHeaders.dup;
    d.maxAgeSeconds = r.maxAgeSeconds;
    d.reason = "Allowed by CORS rule '" ~ r.name ~ "'";
    return d;
  }
  d.reason = rules.length == 0 ? "The bucket has no CORS rules"
    : "No CORS rule allows " ~ enumText(method).toUpper ~ " from " ~ d.origin;
  return d;
}

///
unittest {
  mixin(ShowTest!("matchCors"));

  CorsRule r;
  r.name = "web";
  r.allowedOrigins = ["https://*.example.com/"];
  r.allowedMethods = [CorsMethod.get, CorsMethod.put];
  r.allowedHeaders = ["Content-Type"];
  r.exposedHeaders = ["ETag"];
  validateCorsRule(r);
  assert(r.allowedOrigins == ["https://*.example.com"]);

  auto ok = matchCors([r], "https://app.example.com", CorsMethod.put, ["content-type"]);
  assert(ok.allowed && ok.allowOrigin == "https://app.example.com" && ok.allowMethods == ["GET", "PUT"]);
  assert(!matchCors([r], "https://evil.com", CorsMethod.get, []).allowed);
  assert(!matchCors([r], "https://app.example.com", CorsMethod.delete_, []).allowed);
  assert(!matchCors([r], "https://app.example.com", CorsMethod.get, ["X-Custom"]).allowed);
  assert(!matchCors(null, "https://a.b", CorsMethod.get, []).allowed);

  CorsRule bad;
  bad.name = "bad";
  bad.allowedOrigins = ["ftp://x"];
  bad.allowedMethods = [CorsMethod.get];
  bool rejected;
  try validateCorsRule(bad);
  catch (ObjectStoreValidationException) rejected = true;
  assert(rejected);
}
