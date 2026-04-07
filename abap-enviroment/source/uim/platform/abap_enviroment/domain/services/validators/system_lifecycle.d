/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.domain.services.validators.system_lifecycle;

import uim.platform.abap_enviroment.domain.types;

/// Validation result for system lifecycle transitions.
struct LifecycleValidation {
  bool valid;
  string error;
}

/// Domain service: validates system instance state transitions.
struct SystemLifecycleValidator {
  /// Check whether a status transition is permitted.
  static LifecycleValidation validateTransition(SystemStatus from, SystemStatus target) {
    // Allowed transitions:
    //   provisioning -> active | error
    //   active       -> updating | suspended | deleting
    //   updating     -> active | error
    //   suspended    -> active | deleting
    //   deleting     -> deleted | error
    //   error        -> deleting

    switch (from) {
    case SystemStatus.provisioning:
      if (target == SystemStatus.active
          || target == SystemStatus.error)
        return LifecycleValidation(true, "");
      break;
    case SystemStatus.active:
      if (target == SystemStatus.updating || target == SystemStatus.suspended
          || target == SystemStatus.deleting)
        return LifecycleValidation(true, "");
      break;
    case SystemStatus.updating:
      if (target == SystemStatus.active
          || target == SystemStatus.error)
        return LifecycleValidation(true, "");
      break;
    case SystemStatus.suspended:
      if (target == SystemStatus.active
          || target == SystemStatus.deleting)
        return LifecycleValidation(true, "");
      break;
    case SystemStatus.deleting:
      if (target == SystemStatus.deleted
          || target == SystemStatus.error)
        return LifecycleValidation(true, "");
      break;
    case SystemStatus.error:
      if (target == SystemStatus.deleting)
        return LifecycleValidation(true, "");
      break;
    default:
      break;
    }

    // import std.conv : to;
    return LifecycleValidation(false,
        "Invalid transition from '" ~ from.to!string ~ "' to '" ~ target.to!string ~ "'");
  }

  /// Validate that a system SID is exactly 3 uppercase characters.
  static LifecycleValidation validateSid(string sid) {
    if (sid.length != 3)
      return LifecycleValidation(false, "SAP System ID must be exactly 3 characters");

    foreach (c; sid) {
      if (c < 'A' || c > 'Z')
        return LifecycleValidation(false, "SAP System ID must contain only uppercase letters");
    }

    return LifecycleValidation(true, "");
  }
}
