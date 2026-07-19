/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.application.usecases.manage.ai_requests;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class ManageAIRequestsUseCase {
  private AIRequestRepository  _repo;
  private ProjectValidator     _validator;
  private QuotaService         _quota;

  this(AIRequestRepository repo) {
    _repo      = repo;
    _validator = ProjectValidator();
    _quota     = QuotaService();
  }

  CommandResult generate(TenantId tenantId, AIGenerateRequest req) {
    auto promptErrors = _validator.validatePrompt(req.prompt);
    if (promptErrors.length > 0)
      return CommandResult(false, "", promptErrors[0]);

    AIGenerationType gtype = AIGenerationType.codeFragment;
    static foreach (member; __traits(allMembers, AIGenerationType)) {
      if (req.generationType == mixin("AIGenerationType." ~ member ~ ".to!string"))
        gtype = mixin("AIGenerationType." ~ member);
    }

    auto r = AIRequest(tenantId);
    r.projectId      = ProjectId(req.projectId);
    r.requestedBy    = req.requestedBy;
    r.generationType = gtype;
    r.prompt         = req.prompt;
    r.targetFilePath = req.targetFilePath;
    r.status         = AIRequestStatus.pending;
    r.modelUsed      = "Joule";

    _repo.save(r);
    return CommandResult(true, r.id.value, "");
  }

  AIRequest getById(TenantId tenantId, string id) {
    return _repo.findById(tenantId, AIRequestId(id));
  }

  AIRequest[] list(TenantId tenantId) {
    return _repo.findByTenant(tenantId);
  }

  AIRequest[] listByProject(TenantId tenantId, string projectId) {
    return _repo.findByProject(tenantId, projectId);
  }

  AIRequest[] listByStatus(TenantId tenantId, string statusStr) {
    AIRequestStatus st = AIRequestStatus.pending;
    static foreach (member; __traits(allMembers, AIRequestStatus)) {
      if (statusStr == mixin("AIRequestStatus." ~ member ~ ".to!string"))
        st = mixin("AIRequestStatus." ~ member);
    }
    return _repo.findByStatus(tenantId, st);
  }

  CommandResult updateStatus(TenantId tenantId, string id, string statusStr, string generatedCode = "", string errorMsg = "") {
    auto r = _repo.findById(tenantId, AIRequestId(id));
    if (r.isNull) return CommandResult(false, "", "AI request not found");
    static foreach (member; __traits(allMembers, AIRequestStatus)) {
      if (statusStr == mixin("AIRequestStatus." ~ member ~ ".to!string"))
        r.status = mixin("AIRequestStatus." ~ member);
    }
    if (generatedCode.length > 0) r.generatedCode = generatedCode;
    if (errorMsg.length > 0)      r.errorMessage  = errorMsg;
    _repo.update(r);
    return CommandResult(true, id, "");
  }
}
