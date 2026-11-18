/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Naming rules for buckets and object keys, and glob matching for policies.
module uim.platform.object_store.domain.services.naming;

import std.ascii : isDigit, isLower;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Why `name` is not a valid bucket name ("" if it is). S3 rules:
/// 3–63 characters; lowercase letters, digits, "-" and "."; starts and ends
/// with a letter or digit; no ".."; not an IP address; no "xn--" prefix,
/// "-s3alias" or "--ol-s3" suffix.
string bucketNameError(string name) pure {
  if (name.length < 3 || name.length > 63)
    return "Bucket names must be 3 to 63 characters long";
  foreach (c; name)
    if (!(isLower(c) || isDigit(c) || c == '-' || c == '.'))
      return "Bucket names may only contain lowercase letters, digits, '-' and '.'";
  bool alnum(char c) {
    return isLower(c) || isDigit(c);
  }

  if (!alnum(name[0]) || !alnum(name[$ - 1]))
    return "Bucket names must start and end with a letter or digit";
  if (name.canFind(".."))
    return "Bucket names must not contain two adjacent periods";
  if (name.startsWith("xn--") || name.startsWith("sthree-"))
    return "Bucket names must not start with 'xn--' or 'sthree-'";
  if (name.endsWith("-s3alias") || name.endsWith("--ol-s3"))
    return "Bucket names must not end with '-s3alias' or '--ol-s3'";
  auto parts = name.split(".");
  if (parts.length == 4 && parts.all!(p => p.length > 0 && p.length <= 3 && p.all!isDigit))
    return "Bucket names must not be formatted as an IP address";
  return "";
}

/// Validate a bucket name (422 on violation).
void validateBucketName(string name) {
  auto error = bucketNameError(name);
  validate(error.length == 0, error ~ ": '" ~ name ~ "'");
}

/// Validate an object key: 1–maxLength bytes, no leading "/", no control characters.
void validateObjectKey(string key, int maxLength = 1024) {
  validate(key.length > 0, "Object key is required");
  validate(key.length <= maxLength, "Object keys must not be longer than " ~ maxLength.to!string ~ " bytes");
  validate(key[0] != '/', "Object keys must not start with '/'");
  foreach (c; key)
    validate(c >= 0x20 && c != 0x7f, "Object keys must not contain control characters");
  foreach (segment; key.split("/"))
    validate(segment != "." && segment != "..", "Object keys must not contain '.' or '..' segments");
}

/// A short display name: 1–100 characters, trimmed (policies, rules, bindings).
void validateDisplayName(string kind, string name) {
  validate(name.length > 0, kind ~ " name is required");
  validate(name.length <= 100, kind ~ " names must not be longer than 100 characters");
}

/// Glob match: "*" matches any sequence (also "/"), "?" one character.
bool wildcardMatch(string text, string pattern) pure nothrow {
  size_t t, p, star = size_t.max, mark;
  while (t < text.length) {
    if (p < pattern.length && (pattern[p] == '?' || pattern[p] == text[t])) {
      t++;
      p++;
    } else if (p < pattern.length && pattern[p] == '*') {
      star = p++;
      mark = t;
    } else if (star != size_t.max) {
      p = star + 1;
      t = ++mark;
    } else
      return false;
  }
  while (p < pattern.length && pattern[p] == '*')
    p++;
  return p == pattern.length;
}

///
unittest {
  mixin(ShowTest!("naming"));

  assert(bucketNameError("my-photos.2026") == "");
  assert(bucketNameError("ab").length > 0);
  assert(bucketNameError("My-Bucket").length > 0);
  assert(bucketNameError("-bucket").length > 0);
  assert(bucketNameError("a..b").length > 0);
  assert(bucketNameError("192.168.1.10").length > 0);
  assert(bucketNameError("xn--bucket").length > 0);

  validateObjectKey("images/2026/photo.jpg");
  bool rejected;
  try validateObjectKey("/abs");
  catch (ObjectStoreValidationException) rejected = true;
  assert(rejected);
  rejected = false;
  try validateObjectKey("a/../b");
  catch (ObjectStoreValidationException) rejected = true;
  assert(rejected);

  assert(wildcardMatch("images/2026/a.jpg", "images/*"));
  assert(wildcardMatch("report-2026.pdf", "report-????.pdf"));
  assert(!wildcardMatch("docs/a.txt", "images/*"));
  assert(wildcardMatch("anything", "*"));
  assert(wildcardMatch("", "*"));
  assert(!wildcardMatch("abc", "ab"));
}
