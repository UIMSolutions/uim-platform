/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.types;

/// Unique identifier type alias for type safety.


struct GroupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}



struct ApplicationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct PolicyId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct SessionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TokenId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}



/// Multi-factor authentication type.
enum MfaType {
  none,
  totp,
  sms,
  email,
}



/// User status in the identity directory.
enum UserStatus {
  active,
  inactive,
  locked,
  pendingVerification,
}

/// Risk level determined by risk-based authentication.
enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

/// Token type.
enum TokenType {
  access,
  refresh,
  idToken,
  samlAssertion,
}

/// Provisioning job status.
enum JobStatus {
  pending,
  running,
  completed,
  failed,
}

/// Identity provider type for delegation.
enum IdpType {
  local,
  saml,
  oidc,
  ldap,
  corporate,
}
