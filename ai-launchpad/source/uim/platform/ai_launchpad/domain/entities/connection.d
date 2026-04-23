/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.connection;

// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct Connection {
  ConnectionId id;
  string name;
  ConnectionType type;
  string url;
  string authUrl;
  string clientId;
  string clientSecretMasked;
  ConnectionStatus status;
  string statusMessage;
  WorkspaceId workspaceId;
  string defaultResourceGroupId;
  string description;
  string createdAt;
  string modifiedAt;
}
