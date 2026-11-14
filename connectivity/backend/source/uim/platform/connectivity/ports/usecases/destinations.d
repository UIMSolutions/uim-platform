/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.ports.usecases.destinations;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Maintain destinations and check whether they can be reached.
interface IManageDestinationsUseCase : IManageResource!(Destination, DestinationId,
    CreateDestinationRequest, UpdateDestinationRequest) {
  /// Run a connection check (auth settings, certificate, connector, access rules,
  /// reachability) and store the result in the destination's status.
  UsecaseResult check(TenantId tenantId, DestinationId id, UserId actor);
  /// Destination.init if unknown.
  Destination findByName(TenantId tenantId, string name);
}
