module uim.platform.service.domain.enumerations;

import uim.platform.service;

mixin(ShowModule!());

@safe:
/// SSO protocol.
enum SsoProtocol {
  saml,
  oidc,
}

SsoProtocol toSsoProtocol(string s) {
  switch (s.toLower) {
    // The compiler generates all cases here at compile time!
    static foreach (member; EnumMembers!SsoProtocol) {
  case __traits(identifier, member):
      return member;
    }
  default:
    return SsoProtocol.saml; // Default case
  }
}
/// 
unittest {
  assert(SsoProtocol.saml.to!string == "saml");
  assert(SsoProtocol.oidc.to!string == "oidc");

  assert("saml".to!SsoProtocol == SsoProtocol.saml);
  assert("oidc".to!SsoProtocol == SsoProtocol.oidc);

  assert("saml".toSsoProtocol == SsoProtocol.saml);
  assert("oidc".toSsoProtocol == SsoProtocol.oidc);
  assert("noexists".toSsoProtocol == SsoProtocol.saml); // Default case
  assert("".toSsoProtocol == SsoProtocol.saml); // Default case
}

/// Authentication method supported by the platform.
enum AuthMethod {
  form,
  spnego,
  social,
  certificate,
  saml,
  oidc,
  apiKey,
}

AuthMethod toAuthMethod(string s) {
  switch (s.toLower) {
  case "form":
    return AuthMethod.form;
  case "spnego":
    return AuthMethod.spnego;
  case "social":
    return AuthMethod.social;
  case "certificate":
    return AuthMethod.certificate;
  case "saml":
    return AuthMethod.saml;
  case "oidc":
    return AuthMethod.oidc;
  case "apikey":
    return AuthMethod.apiKey;
  default:
    return AuthMethod.form; // Default case);
  }
}
///
unittest {
  assert(AuthMethod.form.to!string == "form");
  assert(AuthMethod.spnego.to!string == "spnego");
  assert(AuthMethod.social.to!string == "social");
  assert(AuthMethod.certificate.to!string == "certificate");
  assert(AuthMethod.saml.to!string == "saml");
  assert(AuthMethod.oidc.to!string == "oidc");
  assert(AuthMethod.apiKey.to!string == "apiKey");

  assert("form".to!AuthMethod == AuthMethod.form);
  assert("spnego".to!AuthMethod == AuthMethod.spnego);
  assert("social".to!AuthMethod == AuthMethod.social);
  assert("certificate".to!AuthMethod == AuthMethod.certificate);
  assert("saml".to!AuthMethod == AuthMethod.saml);
  assert("oidc".to!AuthMethod == AuthMethod.oidc);
  assert("apiKey".to!AuthMethod == AuthMethod.apiKey);

  assert("form".toAuthMethod == AuthMethod.form);
  assert("spnego".toAuthMethod == AuthMethod.spnego);
  assert("social".toAuthMethod == AuthMethod.social);
  assert("certificate".toAuthMethod == AuthMethod.certificate);
  assert("saml".toAuthMethod == AuthMethod.saml);
  assert("oidc".toAuthMethod == AuthMethod.oidc);
  assert("apiKey".toAuthMethod == AuthMethod.apiKey);
  assert("noexists".toAuthMethod == AuthMethod.form); // Default case
  assert("".toAuthMethod == AuthMethod.form); // Default case
}

enum PersistenceType {
  memory,
  sql,
  nosql,
  file,
}

PersistenceType toPersistenceType(string s) {
  switch (s.toLower()) {
  case "sql":
    return PersistenceType.sql;
  case "nosql":
    return PersistenceType.nosql;
  case "memory":
    return PersistenceType.memory;
  case "file":
    return PersistenceType.file;
  default:
    return PersistenceType.memory; // Default case
  }
}
///
unittest {
  assert(PersistenceType.sql.to!string == "sql");
  assert(PersistenceType.nosql.to!string == "nosql");
  assert(PersistenceType.memory.to!string == "memory");
  assert(PersistenceType.file.to!string == "file");

  assert("sql".to!PersistenceType == PersistenceType.sql);
  assert("nosql".to!PersistenceType == PersistenceType.nosql);
  assert("memory".to!PersistenceType == PersistenceType.memory);
  assert("file".to!PersistenceType == PersistenceType.file);

  assert("sql".toPersistenceType == PersistenceType.sql);
  assert("nosql".toPersistenceType == PersistenceType.nosql);
  assert("memory".toPersistenceType == PersistenceType.memory);
  assert("file".toPersistenceType == PersistenceType.file);
  assert("noexists".toPersistenceType == PersistenceType.memory); // Default case
  assert("".toPersistenceType == PersistenceType.memory); // Default case
}

import std.traits : EnumMembers;

PersistenceType toPersistenceType2(string s) {
  switch (s.toLower) {
    // The compiler generates all cases here at compile time!
    static foreach (member; EnumMembers!PersistenceType) {
  case __traits(identifier, member):
      return member;
    }
  default:
    return PersistenceType.memory; // Default case
  }
}

unittest {
  // Test toPersistenceType
  assert("sql".toPersistenceType2 == PersistenceType.sql);
  assert("nosql".toPersistenceType2 == PersistenceType.nosql);
  assert("memory".toPersistenceType2 == PersistenceType.memory);
  assert("file".toPersistenceType2 == PersistenceType.file);
  assert("noexists".toPersistenceType2 == PersistenceType.memory); // Default case
  assert("".toPersistenceType2 == PersistenceType.memory); // Default case
}

// Alert severity
enum AlertSeverity {
  info,
  warning,
  error,
  critical,
}

AlertSeverity toAlertSeverity(string s) {
  switch (s.toLower()) {
    case "info": return AlertSeverity.info;
    case "warning": return AlertSeverity.warning;
    case "critical": return AlertSeverity.critical;
    // case "fatal": return AlertSeverity.fatal;
    default: return AlertSeverity.info; // default
  }
}

// Log level
enum LoggingLevel {
  info,
  debug_,
  warning,
  error,
  fatal,
  trace
}
LoggingLevel toLoggingLevel(string s) {
  switch (s.toLower()) {
    case "debug": return LoggingLevel.debug_;
    case "info": return LoggingLevel.info;
    case "warning": return LoggingLevel.warning;
    case "error": return LoggingLevel.error;
    case "fatal": return LoggingLevel.fatal;
    case "trace": return LoggingLevel.trace;
    default: return LoggingLevel.info; // default
  }
}