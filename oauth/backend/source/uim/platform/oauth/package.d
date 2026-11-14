/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// OAuth 2.0 authorization server (SAP BTP "OAuth 2.0" service style):
/// client registration, scopes, authorization code (PKCE), client
/// credentials and refresh token grants, JWT access tokens, introspection,
/// revocation and login page branding.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.oauth;

public {
  import uim.platform.service;
  import uim.platform.oauth.domain;
  import uim.platform.oauth.ports;
  import uim.platform.oauth.application;
  import uim.platform.oauth.persistence;
  import uim.platform.oauth.infrastructure;
  import uim.platform.oauth.presentation;
}
