/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.services.connection_validator;

import uim.platform.ai_launchpad.domain.entities.connection : Connection;
import uim.platform.ai_launchpad.domain.types;

struct ValidationResult {
  bool valid;
  string error;
}

class ConnectionValidator {
  ValidationResult validate(Connection c) {
    if (c.name.length == 0) return ValidationResult(false, "Connection name is required");
    if (c.url.length == 0) return ValidationResult(false, "Connection URL is required");
    if (c.authUrl.length == 0) return ValidationResult(false, "Auth URL is required");
    if (c.clientid.isEmpty) return ValidationResult(false, "Client ID is required");
    if (c.workspaceid.isEmpty) return ValidationResult(false, "Workspace ID is required");
    return ValidationResult(true, "");
  }

  bool isReachable(string url) {
    // In production, this would perform an HTTP health check to the runtime
    return url.length > 0;
  }
}
