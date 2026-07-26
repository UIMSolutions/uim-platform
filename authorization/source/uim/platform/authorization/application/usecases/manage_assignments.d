module uim.platform.authorization.application.usecases.manage_assignments;

import std.uuid : randomUUID;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class ManageAssignmentsUseCase {
  private AuthorizationRepository repo;

  this(AuthorizationRepository repo) {
    this.repo = repo;
  }

  UseCaseResult createAssignment(CreatePolicyAssignmentRequest req) {
    if (req.policyId.isEmpty || req.principalType.isEmpty || req.principalId.isEmpty) {
      return UseCaseResult(false, "", "policyId, principalType and principalId are required");
    }

    auto p = repo.findPolicyById(req.tenantId, req.policyId);
    if (p.id.isEmpty) {
      return UseCaseResult(false, "", "Policy not found");
    }

    PolicyAssignment a;
    a.id = randomUUID().toString();
    a.tenantId = req.tenantId;
    a.policyId = req.policyId;
    a.principalType = req.principalType;
    a.principalId = req.principalId;
    a.createdAt = currentTimestamp();

    repo.saveAssignment(a);
    return UseCaseResult(true, a.id, "");
  }

  UseCaseResult deleteAssignment(string tenantId, string assignmentId) {
    auto a = repo.findAssignmentById(tenantId, assignmentId);
    if (a.id.isEmpty) {
      return UseCaseResult(false, "", "Assignment not found");
    }

    repo.deleteAssignment(tenantId, assignmentId);
    return UseCaseResult(true, assignmentId, "");
  }

  PolicyAssignment[] listAssignments(string tenantId) {
    return repo.listAssignments(tenantId);
  }

  PolicyAssignment getAssignment(string tenantId, string assignmentId) {
    return repo.findAssignmentById(tenantId, assignmentId);
  }
}
