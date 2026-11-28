/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A connection to an AI runtime (SAP AI Core or another AI API
/// implementation): service URL, OAuth token URL and client credentials.
/// The client secret is write-only — it is stored for the runtime client
/// but never returned. Every change of the endpoint or the credentials
/// requires a new validation.
module uim.platform.ai_launchpad.domain.entities.connection;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct Connection {
  mixin TenantEntity!ConnectionId;

  WorkspaceId workspaceId;
  string name;
  string description;
  ConnectionType connectionType = ConnectionType.aiCore;
  string url; /// AI API base URL
  string authUrl; /// OAuth 2.0 token endpoint
  string clientId;
  string clientSecret; /// write-only
  string defaultResourceGroup = "default";
  ConnectionStatus status = ConnectionStatus.pending;
  string statusMessage;
  long lastValidatedAt;

  bool isActive() const {
    return status == ConnectionStatus.active;
  }

  bool hasSecret() const {
    return clientSecret.length > 0;
  }

  /// Endpoint or credentials changed: validate again.
  void invalidate(string reason = "Changed: validate the connection") {
    status = ConnectionStatus.pending;
    statusMessage = reason;
  }

  void requireActive(string operation) const {
    if (!isActive)
      throw AilpException.ruleViolation("Connection '" ~ id.value ~ "' is " ~ cast(string) status ~ ": " ~ operation
          ~ " needs a validated (active) connection");
  }

  void validate() const {
    requireId(id.value, "Connection ID");
    requireId(workspaceId.value, "Workspace");
    requireText(name, "Connection name");
    requireMaxLength(name, 200, "Connection name");
    requireMaxLength(description, 2000, "Description");
    requireUrl(url, "Service URL", true);
    requireUrl(authUrl, "Auth URL");
    requireMaxLength(clientId, 512, "Client ID");
    requireMaxLength(clientSecret, 4096, "Client secret");
    if (defaultResourceGroup.length)
      requireId(defaultResourceGroup, "Default resource group");
  }
}

///
unittest {
  Connection c;
  c.id = ConnectionId("aicore-eu");
  c.workspaceId = WorkspaceId("ml");
  c.name = "AI Core EU";
  c.url = "https://api.ai.eu10.example.com/v2";
  c.validate();
  assert(!c.isActive && !c.hasSecret);
  assert(failsWith(AilpErrorKind.ruleViolation, () { c.requireActive("Starting an execution"); }));
  c.url = "api.example.com";
  assert(failsWith(AilpErrorKind.invalid, () { c.validate(); }));
}
