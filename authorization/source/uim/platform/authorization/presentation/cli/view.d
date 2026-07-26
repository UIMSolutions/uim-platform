module uim.platform.authorization.presentation.cli.view;

import std.stdio : writeln;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class AuthorizationCliView {
  void renderSummary(string tenantId, size_t appCount, size_t policyCount, size_t assignmentCount) {
    writeln("Authorization CLI Summary");
    writeln("Tenant: ", tenantId);
    writeln("Applications: ", appCount);
    writeln("Policies: ", policyCount);
    writeln("Assignments: ", assignmentCount);
  }
}
