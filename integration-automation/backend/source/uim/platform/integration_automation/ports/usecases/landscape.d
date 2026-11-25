/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the system landscape and the destinations.
module uim.platform.integration_automation.ports.usecases.landscape;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

interface IManageSystems : IManageResource!(SystemConnection, SystemConnectionId, SystemInput) {
  /// Probe the system and record the result (status, message, time).
  SystemConnection testConnection(TenantId t, SystemConnectionId id, UserId actor);
}

interface IManageDestinations : IManageResource!(Destination, DestinationId, DestinationInput) {
}
