/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.types;

// --- Type Aliases ---
struct SourceSystemId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TargetSystemId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ProxySystemId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TransformationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ProvisioningJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ProvisioningLogId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ProvisionedEntityId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TenantId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct UserId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

// --- Enums ---

/// Type of connected system.
enum SystemType {
  ias,
  ldap,
  sap_hr,
  scim,
  csv,
  azure_ad,
  custom
}

/// Operational status of a system connection.
enum SystemStatus {
  active,
  inactive,
  error,
  configuring
}

/// Role of a system in the provisioning pipeline.
enum SystemRole {
  source,
  target,
  proxy
}

/// Type of provisioning job.
enum JobType {
  full,
  delta,
  simulate
}

/// Status of a provisioning job.
enum JobStatus {
  scheduled,
  running,
  completed,
  failed,
  cancelled
}

/// Type of provisioning operation on a single entity.
enum OperationType {
  create,
  update,
  delete_,
  skip
}

/// Outcome of a single provisioning operation.
enum LogStatus {
  success,
  failed,
  skipped
}

/// Kind of identity entity being provisioned.
enum EntityType {
  user,
  group
}

/// Status of a provisioned entity in a target system.
enum EntityStatus {
  active,
  inactive,
  pending,
  error
}
