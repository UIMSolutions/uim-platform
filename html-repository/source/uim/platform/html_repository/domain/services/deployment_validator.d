/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.services.deployment_validator;

import uim.platform.html_repository.domain.types;

struct DeploymentValidator {
  enum MAX_APP_SIZE_BYTES = 100 * 1024 * 1024; // 100 MB per service instance
  enum MAX_DEPLOYS_PER_MINUTE = 50;
  enum MAX_REQUESTS_PER_SECOND = 300;

  // Validate deployment does not exceed size quota
  static bool validateSize(long currentSizeBytes, long newContentSizeBytes, long quotaMb) {
    auto quotaBytes = quotaMb * 1024 * 1024;
    return (currentSizeBytes + newContentSizeBytes) <= quotaBytes;
  }

  // Validate app name (alphanumeric with dots and hyphens)
  static bool validateAppName(string name) {
    if (name.length == 0 || name.length > 255)
      return false;
    import std.regex : regex, matchAll;

    auto pat = regex(`^[a-zA-Z0-9][a-zA-Z0-9_\-.]*$`);
    auto m = matchAll(name, pat);
    return !m.empty;
  }

  // Validate version code (semantic versioning pattern)
  static bool validateVersionCode(string version_) {
    if (version_.length == 0 || version_.length > 50)
      return false;
    import std.regex : regex, matchAll;

    auto pat = regex(`^[0-9]+\.[0-9]+\.[0-9]+([a-zA-Z0-9_\-.]*)?$`);
    auto m = matchAll(version_, pat);
    return !m.empty;
  }

  // Validate file path within an app
  static bool validateFilePath(string path) {
    if (path.length == 0 || path.length > 512)
      return false;
    // Must not start with / or contain ..
    if (path[0] == '/')
      return false;
    import std.string : indexOf;

    if (indexOf(path, "..") >= 0)
      return false;
    return true;
  }

  // Validate service instance name
  static bool validateInstanceName(string name) {
    if (name.length == 0 || name.length > 100)
      return false;
    import std.regex : regex, matchAll;

    auto pat = regex(`^[a-zA-Z0-9][a-zA-Z0-9_\-]*$`);
    auto m = matchAll(name, pat);
    return !m.empty;
  }

  // Validate route path prefix
  static bool validatePathPrefix(string prefix) {
    if (prefix.length == 0 || prefix.length > 255)
      return false;
    if (prefix[0] != '/')
      return false;
    return true;
  }

  // Full deployment validation
  static string validate(string appName, string version_, long currentSizeBytes, long newSizeBytes, long quotaMb) {
    if (!validateAppName(appName))
      return "Invalid application name (must be 1-255 alphanumeric with dots/hyphens)";
    if (!validateVersionCode(version_))
      return "Invalid version code (must follow semantic versioning)";
    if (!validateSize(currentSizeBytes, newSizeBytes, quotaMb))
      return "Deployment would exceed storage quota";
    return "";
  }
}
