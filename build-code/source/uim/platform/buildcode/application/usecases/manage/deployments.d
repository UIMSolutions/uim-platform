/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.application.usecases.manage.deployments;

import uim.platform.buildcode;
import std.conv : to;

mixin(ShowModule!());

@safe:

class ManageDeploymentsUseCase {
  private DeploymentRepository  _repo;

  this(DeploymentRepository repo) { _repo = repo; }

  CommandResult create(string tenantId, CreateDeploymentRequest req) {
    DeploymentEnvironment env = DeploymentEnvironment.cloudFoundry;
    static foreach (member; __traits(allMembers, DeploymentEnvironment)) {
      if (req.targetEnvironment == mixin("DeploymentEnvironment." ~ member ~ ".to!string"))
        env = mixin("DeploymentEnvironment." ~ member);
    }

    Deployment d;
    d.initEntity(tenantId);
    d.projectId         = ProjectId(req.projectId);
    d.buildJobId        = BuildJobId(req.buildJobId);
    d.artifactVersion   = req.artifactVersion;
    d.targetEnvironment = env;
    d.status            = DeploymentStatus.pending;
    d.targetOrg         = req.targetOrg;
    d.targetSpace       = req.targetSpace;
    d.deployedBy        = req.deployedBy;
    d.deployedAtMs      = 0;

    _repo.save(d);
    return CommandResult(true, d.id.value, "");
  }

  Deployment getById(string tenantId, string id) {
    return _repo.findById(tenantId, DeploymentId(id));
  }

  Deployment[] list(string tenantId) {
    return _repo.findByTenant(tenantId);
  }

  Deployment[] listByProject(string tenantId, string projectId) {
    return _repo.findByProject(tenantId, projectId);
  }

  Deployment[] listByEnvironment(string tenantId, string envStr) {
    DeploymentEnvironment env = DeploymentEnvironment.other;
    static foreach (member; __traits(allMembers, DeploymentEnvironment)) {
      if (envStr == mixin("DeploymentEnvironment." ~ member ~ ".to!string"))
        env = mixin("DeploymentEnvironment." ~ member);
    }
    return _repo.findByEnvironment(tenantId, env);
  }

  CommandResult updateStatus(string tenantId, string id, string statusStr, string url = "") {
    auto d = _repo.findById(tenantId, DeploymentId(id));
    if (d.isNull) return CommandResult(false, "", "Deployment not found");
    static foreach (member; __traits(allMembers, DeploymentStatus)) {
      if (statusStr == mixin("DeploymentStatus." ~ member ~ ".to!string"))
        d.status = mixin("DeploymentStatus." ~ member);
    }
    if (url.length > 0) d.targetUrl = url;
    _repo.update(d);
    return CommandResult(true, id, "");
  }
}
