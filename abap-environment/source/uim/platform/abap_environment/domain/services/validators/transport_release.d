/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.services.transport_release_validator;

import uim.platform.abap_environment.domain.entities.transport_request;
import uim.platform.abap_environment.domain.types;

/// Validation result for transport operations.
struct TransportValidation {
  bool valid;
  string[] errors;
}

/// Domain service: validates transport request release preconditions.
struct TransportReleaseValidator {
  /// Validate that a transport request can be released.
  static TransportValidation validateRelease(const TransportRequest request) {
    string[] errors;

    if (request.status != TransportStatus.modifiable)
      errors ~= "Transport request is not in modifiable status";

    if (request.description.length == 0)
      errors ~= "Transport request must have a description";

    if (request.owner.length == 0)
      errors ~= "Transport request must have an owner";

    // All tasks must be released before the request
    foreach (task; request.tasks) {
      if (task.status == TransportStatus.modifiable) {
        errors ~= "Task '" ~ task.taskId ~ "' is still modifiable - release all tasks first";
      }
    }

    return TransportValidation(errors.length == 0, errors);
  }

  /// Validate that a transport task can be released.
  static TransportValidation validateTaskRelease(const TransportTask task) {
    string[] errors;

    if (task.status != TransportStatus.modifiable)
      errors ~= "Task is not in modifiable status";

    if (task.owner.length == 0)
      errors ~= "Task must have an owner";

    return TransportValidation(errors.length == 0, errors);
  }
}
