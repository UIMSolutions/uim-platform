module uim.platform.abap_enviroment.domain.services.transport_release_validator;

import uim.platform.abap_enviroment.domain.entities.transport_request;
import uim.platform.abap_enviroment.domain.types;

/// Validation result for transport operations.
struct TransportValidation
{
  bool valid;
  string[] errors;
}

/// Domain service: validates transport request release preconditions.
struct TransportReleaseValidator
{
  /// Validate that a transport request can be released.
  static TransportValidation validateRelease(ref const TransportRequest request)
  {
    string[] errors;

    if (request.status != TransportStatus.modifiable)
      errors ~= "Transport request is not in modifiable status";

    if (request.description.length == 0)
      errors ~= "Transport request must have a description";

    if (request.owner.length == 0)
      errors ~= "Transport request must have an owner";

    // All tasks must be released before the request
    foreach (ref task; request.tasks)
    {
      if (task.status == TransportStatus.modifiable)
      {
        errors ~= "Task '" ~ task.taskId ~ "' is still modifiable - release all tasks first";
      }
    }

    return TransportValidation(errors.length == 0, errors);
  }

  /// Validate that a transport task can be released.
  static TransportValidation validateTaskRelease(ref const TransportTask task)
  {
    string[] errors;

    if (task.status != TransportStatus.modifiable)
      errors ~= "Task is not in modifiable status";

    if (task.owner.length == 0)
      errors ~= "Task must have an owner";

    return TransportValidation(errors.length == 0, errors);
  }
}
