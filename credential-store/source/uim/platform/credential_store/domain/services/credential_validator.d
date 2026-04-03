/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.services.credential_validator;

import uim.platform.credential_store.domain.types;

import std.regex : regex, matchAll;

struct CredentialValidator {
  static bool validateName(string name) {
    return name.length > 0 && name.length <= 255;
  }

  static bool validatePasswordValue(string value) {
    return value.length > 0 && value.length <= 4096;
  }

  static bool validateKeyValue(string value) {
    // base64-encoded, up to 32 KB decoded
    return value.length > 0 && value.length <= 43_690; // ~32KB in base64
  }

  static bool validateMetadata(string metadata) {
    return metadata.length <= 10_000;
  }

  static bool validateFormat(string format) {
    return format.length <= 255;
  }

  static bool validateUsername(string username) {
    return username.length <= 1024;
  }

  static bool validateNamespaceName(string name) {
    if (name.length == 0 || name.length > 100)
      return false;
    // allowed: letters, digits, _ - . : ! ~
    auto pat = regex(`^[a-zA-Z0-9_\-.:!~]+$`);
    auto m = matchAll(name, pat);
    return !m.empty;
  }

  static string validate(string name, string value, CredentialType type, string metadata, string format, string username) {
    if (!validateName(name))
      return "Credential name must be 1-255 characters";
    if (!validateMetadata(metadata))
      return "Metadata must be at most 10,000 characters";
    if (!validateFormat(format))
      return "Format must be at most 255 characters";

    final switch (type) {
    case CredentialType.password:
      if (!validatePasswordValue(value))
        return "Password value must be 1-4096 characters";
      if (!validateUsername(username))
        return "Username must be at most 1024 characters";
      break;
    case CredentialType.key:
      if (!validateKeyValue(value))
        return "Key value must be 1-32KB (base64-encoded)";
      break;
    case CredentialType.keyring:
      // keyrings are auto-generated, value validation may differ
      break;
    }

    return "";
  }
}
