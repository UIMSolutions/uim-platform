/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.application.dto;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Shared result type
// ---------------------------------------------------------------------------
struct CommandResult {
  bool   success;
  string id;
  string error;
}

// ---------------------------------------------------------------------------
// OAuth 2.0 Client DTOs
// ---------------------------------------------------------------------------
struct CreateOAuthClientRequest {
  string   clientId;
  string   clientSecret;
  string   name;
  string   description;
  string[] grantTypes;    // e.g. ["client_credentials", "authorization_code"]
  string[] scopes;
  string[] redirectUris;
  string   clientType;    // "confidential" | "public"
  string   appId;
}

struct UpdateOAuthClientRequest {
  OAuthClientId id;
  string        name;
  string        description;
  string[]      grantTypes;
  string[]      scopes;
  string[]      redirectUris;
}

// ---------------------------------------------------------------------------
// Scope DTOs
// ---------------------------------------------------------------------------
struct CreateScopeRequest {
  string name;
  string description;
  string appId;
}

struct UpdateScopeRequest {
  ScopeId id;
  string  description;
}

// ---------------------------------------------------------------------------
// Role DTOs
// ---------------------------------------------------------------------------
struct CreateRoleRequest {
  string   name;
  string   description;
  string[] scopeReferences;
  string   appId;
}

struct UpdateRoleRequest {
  RoleId   id;
  string   description;
  string[] scopeReferences;
}

// ---------------------------------------------------------------------------
// Role Collection DTOs
// ---------------------------------------------------------------------------
struct CreateRoleCollectionRequest {
  string   name;
  string   description;
  string[] roleReferences;
}

struct UpdateRoleCollectionRequest {
  RoleCollectionId id;
  string           description;
  string[]         roleReferences;
}

// ---------------------------------------------------------------------------
// User Assignment DTOs
// ---------------------------------------------------------------------------
struct CreateUserAssignmentRequest {
  string           userId;
  string           userEmail;
  RoleCollectionId roleCollectionId;
  string           origin;
}

// ---------------------------------------------------------------------------
// Identity Provider DTOs
// ---------------------------------------------------------------------------
struct CreateIdentityProviderRequest {
  string alias_;
  string displayName;
  string idpType;       // "saml2" | "oidc"
  string metadataUrl;
  string entityId;
  string ssoUrl;
  string sloUrl;
  string signingCert;
  bool   isActive;
  bool   isDefault;
}

struct UpdateIdentityProviderRequest {
  IdentityProviderId id;
  string             displayName;
  string             metadataUrl;
  string             ssoUrl;
  string             sloUrl;
  string             signingCert;
  bool               isActive;
  bool               isDefault;
}

// ---------------------------------------------------------------------------
// Token DTOs
// ---------------------------------------------------------------------------
struct IssueTokenRequest {
  string   grantType;       // "client_credentials" | "authorization_code"
  string   clientId;
  string   clientSecret;
  string   code;            // for authorization_code flow
  string   redirectUri;
  string[] scope;
}

struct TokenResponse {
  string   accessToken;
  string   tokenType;       // "Bearer"
  int      expiresIn;
  string[] grantedScopes;
}
