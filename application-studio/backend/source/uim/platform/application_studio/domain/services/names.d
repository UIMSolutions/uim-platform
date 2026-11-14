/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Naming and format rules of dev spaces, projects, extensions, URLs and e-mails.
module uim.platform.application_studio.domain.services.names;

import std.ascii : isAlpha, isAlphaNum, isDigit, isLower, isUpper;
import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// A display name (dev space type, template title, binding, configuration): 1–80 characters, no outer blanks.
void validateDisplayName(string kind, string name) {
  validate(name.strip.length > 0, kind ~ " name is required");
  validate(name.length <= 80, kind ~ " name must not exceed 80 characters");
  validate(name == name.strip, kind ~ " name must not start or end with blanks");
}

/// A dev space name: 1–40 letters, digits or "_", starting with a letter (SAP BAS rule).
void validateDevSpaceName(string name) {
  validate(name.length > 0, "Dev space name is required");
  validate(name.length <= 40, "Dev space name must not exceed 40 characters");
  validate(isAlpha(name[0]), "Dev space name must start with a letter (got '" ~ name ~ "')");
  foreach (c; name)
    validate(isAlphaNum(c) || c == '_', "Dev space name may only contain letters, digits and '_' (got '" ~ name ~ "')");
}

/// A project (folder / npm package) name: 1–64 lowercase letters, digits, "-", "_", ".", starting with a letter.
void validateProjectName(string name) {
  validate(name.length > 0, "Project name is required");
  validate(name.length <= 64, "Project name must not exceed 64 characters");
  validate(isLower(name[0]), "Project name must start with a lowercase letter (got '" ~ name ~ "')");
  foreach (c; name)
    validate(isLower(c) || isDigit(c) || c == '-' || c == '_' || c == '.',
      "Project name may only contain a–z, 0–9, '-', '_' and '.' (got '" ~ name ~ "')");
}

/// An extension or template id: lowercase "publisher.package" or "package" with a–z, 0–9, "-", ".".
void validateCatalogName(string kind, string name) {
  validate(name.length > 0, kind ~ " name is required");
  validate(name.length <= 80, kind ~ " name must not exceed 80 characters");
  validate(isLower(name[0]), kind ~ " name must start with a lowercase letter (got '" ~ name ~ "')");
  foreach (c; name)
    validate(isLower(c) || isDigit(c) || c == '-' || c == '.', kind ~ " name may only contain a–z, 0–9, '-' and '.' (got '" ~ name ~ "')");
  validate(!name.endsWith(".") && !name.canFind(".."), kind ~ " name '" ~ name ~ "' has an empty segment");
}

/// A semantic version "major.minor.patch" (optionally with "-prerelease").
bool isSemVer(string v) pure {
  auto core = v.indexOf('-') >= 0 ? v[0 .. v.indexOf('-')] : v;
  auto parts = core.split(".");
  if (parts.length != 3)
    return false;
  foreach (p; parts)
    if (p.length == 0 || !p.all!(c => c >= '0' && c <= '9'))
      return false;
  return true;
}

void validateSemVer(string kind, string v) {
  validate(isSemVer(v), kind ~ " version '" ~ v ~ "' must look like 1.2.3");
}

/// A plausible e-mail address (local@domain.tld).
bool isValidEmail(string email) pure {
  auto at = email.indexOf('@');
  if (at <= 0 || at != email.lastIndexOf('@') || email.canFind(' '))
    return false;
  auto domain = email[at + 1 .. $];
  auto dot = domain.lastIndexOf('.');
  return dot > 0 && dot < cast(long) domain.length - 2;
}

void validateEmail(string what, string email) {
  validate(email.length > 0, what ~ " is required");
  validate(isValidEmail(email), what ~ " '" ~ email ~ "' is not a valid e-mail address");
}

/// An http(s) URL.
bool isHttpUrl(string url) pure {
  return (url.startsWith("https://") && url.length > 8) || (url.startsWith("http://") && url.length > 7);
}

/// A git remote: http(s) URL or scp-like "git@host:org/repo.git".
bool isGitUrl(string url) pure {
  if (isHttpUrl(url))
    return true;
  auto at = url.indexOf('@');
  auto colon = url.indexOf(':');
  return at > 0 && colon > at + 1 && colon < cast(long) url.length - 1 && !url.canFind(' ');
}

/// An environment variable name: letter or "_" first, then letters, digits, "_".
bool isEnvName(string name) pure {
  if (name.length == 0 || !(isAlpha(name[0]) || name[0] == '_'))
    return false;
  return name.all!(c => isAlphaNum(c) || c == '_');
}

/// A TCP port a run may listen on (no privileged ports).
void validatePort(string what, int port) {
  validate(port >= 1024 && port <= 65_535, what ~ " must be between 1024 and 65535 (got " ~ port.to!string ~ ")");
}

/// Names normalised: trimmed, empty entries dropped, duplicates removed (order kept).
string[] normalizedNames(const string[] names) {
  string[] result;
  foreach (n; names) {
    auto s = n.strip;
    if (s.length > 0 && !result.canFind(s))
      result ~= s;
  }
  return result;
}

///
unittest {
  bool failed(void delegate() @safe f) {
    try
      f();
    catch (StudioValidationException)
      return true;
    return false;
  }

  validateDevSpaceName("Fiori_Dev1");
  assert(failed(() => validateDevSpaceName("1dev")));
  assert(failed(() => validateDevSpaceName("my-dev")));
  assert(failed(() => validateDevSpaceName("a".replicate(41))));

  validateProjectName("travel-app.ui");
  assert(failed(() => validateProjectName("Travel")));
  assert(failed(() => validateProjectName("travel app")));

  validateCatalogName("Extension", "sap.fiori-tools");
  assert(failed(() => validateCatalogName("Extension", "SAP.Fiori")));
  assert(failed(() => validateCatalogName("Extension", "sap..x")));

  assert(isSemVer("1.20.3") && isSemVer("2.0.0-beta") && !isSemVer("1.2") && !isSemVer("1.x.0"));
  assert(isValidEmail("jane.doe@example.com") && !isValidEmail("jane@x"));
  assert(isGitUrl("https://github.com/acme/travel.git") && isGitUrl("git@github.com:acme/travel.git") && !isGitUrl("travel"));
  assert(isEnvName("NODE_ENV") && isEnvName("_x1") && !isEnvName("1A") && !isEnvName("A-B"));
  assert(failed(() => validatePort("Port", 80)));
  assert(normalizedNames([" a", "b", "a", ""]) == ["a", "b"]);
}
