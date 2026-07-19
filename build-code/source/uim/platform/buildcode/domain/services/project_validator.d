/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.services.project_validator;

import uim.platform.buildcode;
mixin(ShowModule!());

@safe:

/// Domain-level validation for Project creation / updates
struct ProjectValidator {

  string[] validateName(string name) {
    string[] errors;
    if (name.isEmpty)
      errors ~= "Project name must not be empty";
    if (name.length > 128)
      errors ~= "Project name must not exceed 128 characters";
    foreach (ch; name) {
      if (ch != '-' && ch != '_' && ch != '.' && !(ch >= 'a' && ch <= 'z') &&
          !(ch >= 'A' && ch <= 'Z') && !(ch >= '0' && ch <= '9') && ch != ' ')
        errors ~= "Project name contains invalid character: " ~ ch;
    }
    return errors;
  }

  string[] validateRepositoryUrl(string url) {
    string[] errors;
    if (url.length > 0) {
      if (url.length > 512)
        errors ~= "Repository URL must not exceed 512 characters";
    }
    return errors;
  }

  string[] validatePrompt(string prompt) {
    string[] errors;
    if (prompt.length == 0)
      errors ~= "AI generation prompt must not be empty";
    if (prompt.length > 4096)
      errors ~= "AI generation prompt must not exceed 4096 characters";
    return errors;
  }
}
