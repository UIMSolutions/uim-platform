/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.services.transport_validator;

import uim.platform.content_agent.domain.entities.transport_request;
import uim.platform.content_agent.domain.entities.content_package;
import uim.platform.content_agent.domain.entities.transport_queue;
import uim.platform.content_agent.domain.types;

/// Result of transport validation.
struct TransportValidationResult {
  bool valid;
  string[] errors;
}

/// Domain service: validates transport requests.
struct TransportValidator {
  /// Validate a transport request against its packages and target queue.
  static TransportValidationResult validate(const ref TransportRequest request,
      const ContentPackage[] packages, const ref TransportQueue queue) {
    string[] errors;

    if (request.packageIds.length == 0)
      errors ~= "Transport request must reference at least one package";

    if (request.sourceSubaccount.length == 0)
      errors ~= "Source subaccount is required";

    if (request.targetSubaccount.length == 0)
      errors ~= "Target subaccount is required";

    if (request.sourceSubaccount == request.targetSubaccount)
      errors ~= "Source and target subaccounts must differ";

    // Verify all referenced packages exist and are in assembled state
    bool[string] pkgIds;
    foreach (p; packages)
      pkgIds[p.id] = true;

    foreach (pid; request.packageIds) {
      if (pid !in pkgIds)
        errors ~= "Referenced package not found: " ~ pid;
    }

    foreach (p; packages) {
      if (p.status != PackageStatus.assembled && p.status != PackageStatus.exported)
        errors ~= "Package '" ~ p.name ~ "' is not in assembled/exported state";
    }

    // Validate queue
    if (queue.isNull)
      errors ~= "Transport queue not found";

    // Validate mode vs queue type compatibility
    if (request.mode == TransportMode.ctsPlus && queue.queueType != QueueType.ctsPlus)
      errors ~= "CTS+ transport mode requires a CTS+ queue";

    if (request.mode == TransportMode.cloudTransportManagement
        && queue.queueType != QueueType.cloudTMS)
      errors ~= "Cloud TMS transport mode requires a Cloud TMS queue";

    return TransportValidationResult(errors.length == 0, errors);
  }
}
