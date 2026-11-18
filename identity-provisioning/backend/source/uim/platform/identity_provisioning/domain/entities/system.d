/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.domain.entities.system;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Fields shared by source, target and proxy systems (the connector
/// configuration). Mixed into the entity structs, so the reflection codec
/// sees them as ordinary fields.
mixin template ConnectedSystem() {
  string name;
  string description;
  SystemType systemType = SystemType.scim;
  SystemStatus status = SystemStatus.configuring;
  string url;
  AuthenticationType authenticationType = AuthenticationType.basic;
  string user; /// user or OAuth client id
  string password; /// password or client secret — masked by every adapter
  Attribute[] properties; /// connector properties, e.g. "ldap.user.filter"
  string statusMessage;
  long lastTestedAt;
  long lastSyncAt;
  int entityCount; /// entities read (source) / written (target) in the last run

  /// The settings handed to the connector gateway.
  ConnectionSettings connection() const {
    ConnectionSettings s;
    s.systemName = name;
    s.systemType = systemType;
    s.url = url;
    s.authenticationType = authenticationType;
    s.user = user;
    s.password = password;
    foreach (p; properties)
      s.properties ~= Attribute(p.key, p.value);
    return s;
  }
}
