/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.dtos.specs;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

// ── Source, target and proxy systems ─────────────────────────────────────────

struct SystemSpec {
  string name;
  string description;
  SystemType systemType = SystemType.scim;
  string url;
  AuthenticationType authenticationType = AuthenticationType.basic;
  string user;
  string password;
  Attribute[] properties;
}

alias CreateSystemRequest = CreateRootRequest!SystemSpec;
alias UpdateSourceSystemRequest = UpdateRequest!(SourceSystemId, SystemSpec);
alias UpdateTargetSystemRequest = UpdateRequest!(TargetSystemId, SystemSpec);
alias UpdateProxySystemRequest = UpdateRequest!(ProxySystemId, SystemSpec);

// ── Transformations ──────────────────────────────────────────────────────────

struct TransformationSpec {
  string name;
  string description;
  SystemRole systemRole = SystemRole.target;
  string systemId; /// id (or unique name) of the system
  EntityScope scope_ = EntityScope.all;
  int sequence = 10;
  bool active = true;
  AttributeMapping[] mappings;
  EntityCondition[] conditions;
}

alias CreateTransformationRequest = CreateRootRequest!TransformationSpec;
alias UpdateTransformationRequest = UpdateRequest!(TransformationId, TransformationSpec);

// ── Provisioning jobs ────────────────────────────────────────────────────────

struct JobSpec {
  string name; /// "" = "<source> → <target> (<type>)"
  string description;
  SourceSystemId sourceSystemId;
  TargetSystemId targetSystemId;
  JobType jobType = JobType.delta;
  int intervalMinutes; /// 0 = on demand
}

alias CreateJobRequest = CreateRootRequest!JobSpec;
alias UpdateJobRequest = UpdateRequest!(ProvisioningJobId, JobSpec);
