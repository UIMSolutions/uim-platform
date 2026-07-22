/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.enumerations;

import uim.platform.identity.provisioning;

mixin(ShowModule!());

@safe:

// --- Enums ---
/// Type of connected system.
enum SystemType {
  ias, // SAP Identity Authentication Service
  ldap, // Generic LDAP directory
  sap_hr, // 
  scim, // Systems supporting SCIM protocol
  csv, // Comma-separated values file
  azure_ad, // Microsoft Azure Active Directory
  custom // Custom system type
}

SystemType toSystemType(string s) {
  mixin(EnumSwitch("SystemType", "custom"));
}

SystemType[] toSystemTypes(string[] values)
  => values.map!toSystemType.array;

string toString(SystemType value)
  => value.to!string;

string[] toStrings(SystemType[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("SystemType"));

  assert("ias".toSystemType == SystemType.ias);
  assert("ldap".toSystemType == SystemType.ldap);
  assert("sap_hr".toSystemType == SystemType.sap_hr);
  assert("scim".toSystemType == SystemType.scim);
  assert("csv".toSystemType == SystemType.csv);
  assert("azure_ad".toSystemType == SystemType.azure_ad);
  assert("custom".toSystemType == SystemType.custom);

  assert("".toSystemType == SystemType.custom);
  assert("unknown".toSystemType == SystemType.custom);

  assert(SystemType.ias.toString == "ias");
  assert(SystemType.ldap.toString == "ldap");
  assert(SystemType.sap_hr.toString == "sap_hr");
  assert(SystemType.scim.toString == "scim");
  assert(SystemType.csv.toString == "csv");
  assert(SystemType.azure_ad.toString == "azure_ad");
  assert(SystemType.custom.toString == "custom");

  assert(["ias", "scim"].toSystemTypes == [
      SystemType.ias, SystemType.scim
    ]);
  assert([SystemType.ias, SystemType.scim].toStrings == ["ias", "scim"]);
}

/// Operational status of a system connection.
enum SystemStatus {
  active, // System connection is active and operational
  inactive, // System connection is inactive or disabled
  error, // System connection is in error state (e.g. failed connectivity tests)
  configuring // System connection is being configured or tested
}

SystemStatus toSystemStatus(string s) {
  mixin(EnumSwitch("SystemStatus", "active"));
}

SystemStatus[] toSystemStatuses(string[] values)
  => values.map!toSystemStatus.array;

string toString(SystemStatus value)
  => value.to!string;

string[] toStrings(SystemStatus[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("SystemStatus"));

  assert("active".toSystemStatus == SystemStatus.active);
  assert("inactive".toSystemStatus == SystemStatus.inactive);
  assert("error".toSystemStatus == SystemStatus.error);
  assert("configuring".toSystemStatus == SystemStatus.configuring);

  assert("".toSystemStatus == SystemStatus.active);
  assert("unknown".toSystemStatus == SystemStatus.active);

  assert(SystemStatus.active.toString == "active");
  assert(SystemStatus.inactive.toString == "inactive");
  assert(SystemStatus.error.toString == "error");
  assert(SystemStatus.configuring.toString == "configuring");

  assert(["active", "error"].toSystemStatuses == [
      SystemStatus.active, SystemStatus.error
    ]);
  assert([SystemStatus.active, SystemStatus.error].toStrings == ["active", "error"]);
}

/// Role of a system in the provisioning pipeline.
enum SystemRole {
  source, // System is a source of identity data (e.g. HR system)
  target, // System is a target for provisioning (e.g. cloud application)
  proxy // System acts as a proxy or middleware in the provisioning flow
}

SystemRole toSystemRole(string s) {
  mixin(EnumSwitch("SystemRole", "source"));
}

SystemRole[] toSystemRoles(string[] values)
  => values.map!toSystemRole.array;

string toString(SystemRole value)
  => value.to!string;

string[] toStrings(SystemRole[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("SystemRole"));

  assert("source".toSystemRole == SystemRole.source);
  assert("target".toSystemRole == SystemRole.target);
  assert("proxy".toSystemRole == SystemRole.proxy);

  assert("".toSystemRole == SystemRole.source);
  assert("unknown".toSystemRole == SystemRole.source);

  assert(SystemRole.source.toString == "source");
  assert(SystemRole.target.toString == "target");
  assert(SystemRole.proxy.toString == "proxy");

  assert(["source", "proxy"].toSystemRoles == [
      SystemRole.source, SystemRole.proxy
    ]);
  assert([SystemRole.source, SystemRole.proxy].toStrings == ["source", "proxy"]);
}

/// Type of provisioning job.
enum JobType {
  full, // Full provisioning - all entities are provisioned regardless of previous state
  delta, // Delta provisioning - only entities that have changed since last successful run are provisioned
  simulate // Simulation mode - provisioning logic is executed but no actual changes are made to target systems
}

JobType toJobType(string s) {
  mixin(EnumSwitch("JobType", "full"));
}

JobType[] toJobTypes(string[] values)
  => values.map!toJobType.array;

string toString(JobType value)
  => value.to!string;

string[] toStrings(JobType[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("JobType"));

  assert("full".toJobType == JobType.full);
  assert("delta".toJobType == JobType.delta);
  assert("simulate".toJobType == JobType.simulate);

  assert("".toJobType == JobType.full);
  assert("unknown".toJobType == JobType.full);

  assert(JobType.full.toString == "full");
  assert(JobType.delta.toString == "delta");
  assert(JobType.simulate.toString == "simulate");

  assert(["full", "simulate"].toJobTypes == [
      JobType.full, JobType.simulate
    ]);
  assert([JobType.full, JobType.simulate].toStrings == ["full", "simulate"]);
}

/// Status of a provisioning job.
enum JobStatus {
  scheduled, // Job is scheduled but not yet started
  running, // Job is currently running
  completed, // Job has completed successfully
  failed, // Job has failed
  cancelled // Job has been cancelled
}

JobStatus toJobStatus(string s) {
  mixin(EnumSwitch("JobStatus", "scheduled"));
}

JobStatus[] toJobStatuses(string[] values)
  => values.map!toJobStatus.array;

string toString(JobStatus value)
  => value.to!string;

string[] toStrings(JobStatus[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("JobStatus"));

  assert("scheduled".toJobStatus == JobStatus.scheduled);
  assert("running".toJobStatus == JobStatus.running);
  assert("completed".toJobStatus == JobStatus.completed);
  assert("failed".toJobStatus == JobStatus.failed);
  assert("cancelled".toJobStatus == JobStatus.cancelled);

  assert("".toJobStatus == JobStatus.scheduled);
  assert("unknown".toJobStatus == JobStatus.scheduled);

  assert(JobStatus.scheduled.toString == "scheduled");
  assert(JobStatus.running.toString == "running");
  assert(JobStatus.completed.toString == "completed");
  assert(JobStatus.failed.toString == "failed");
  assert(JobStatus.cancelled.toString == "cancelled");

  assert(["scheduled", "failed"].toJobStatuses == [
      JobStatus.scheduled, JobStatus.failed
    ]);
  assert([JobStatus.scheduled, JobStatus.failed].toStrings == ["scheduled", "failed"]);
}

/// Type of provisioning operation on a single entity.
enum OperationType {
  create, // Create new entity in target system
  update, // Update existing entity in target system
  delete_, // Delete entity from target system 
  skip // Skip operation (e.g. due to filters or errors)
}

OperationType toOperationType(string value) {
  switch (value.toLower) {
  case "create":
    return OperationType.create;
  case "update":
    return OperationType.update;
  case "delete":
  case "delete_":
    return OperationType.delete_;
  case "skip":
    return OperationType.skip;
  default:
    return OperationType.skip; // Default case  
}

OperationType[] toOperationTypes(string[] values)
  => values.map!toOperationType.array;

string toString(OperationType value)
  => value.to!string;

string[] toStrings(OperationType[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("OperationType"));

  assert("create".toOperationType == OperationType.create);
  assert("update".toOperationType == OperationType.update);
  assert("delete".toOperationType == OperationType.delete_);
  assert("delete_".toOperationType == OperationType.delete_);
  assert("skip".toOperationType == OperationType.skip);

  assert("".toOperationType == OperationType.skip);
  assert("unknown".toOperationType == OperationType.skip);

  assert(OperationType.create.toString == "create");
  assert(OperationType.update.toString == "update");
  assert(OperationType.delete_.toString == "delete_");
  assert(OperationType.skip.toString == "skip");

  assert(["create", "skip"].toOperationTypes == [
      OperationType.create, OperationType.skip
    ]);
  assert([OperationType.create, OperationType.skip].toStrings == ["create", "skip"]);
}

/// Outcome of a single provisioning operation.
enum LogStatus {
  success, // Operation completed successfully
  failed, // Operation failed
  skipped // Operation was skipped
}

LogStatus toLogStatus(string s) {
  mixin(EnumSwitch("LogStatus", "success"));
}

LogStatus[] toLogStatuses(string[] values)
  => values.map!toLogStatus.array;

string toString(LogStatus value)
  => value.to!string;

string[] toStrings(LogStatus[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("LogStatus"));

  assert("success".toLogStatus == LogStatus.success);
  assert("failed".toLogStatus == LogStatus.failed);
  assert("skipped".toLogStatus == LogStatus.skipped);

  assert("".toLogStatus == LogStatus.success);
  assert("unknown".toLogStatus == LogStatus.success);

  assert(LogStatus.success.toString == "success");
  assert(LogStatus.failed.toString == "failed");
  assert(LogStatus.skipped.toString == "skipped");

  assert(["success", "skipped"].toLogStatuses == [
      LogStatus.success, LogStatus.skipped
    ]);
  assert([LogStatus.success, LogStatus.skipped].toStrings == ["success", "skipped"]);
}

/// Kind of identity entity being provisioned.
enum EntityType {
  user, // User entity
  group // Group or role entity
}

EntityType toEntityType(string s) {
  mixin(EnumSwitch("EntityType", "user"));
}

EntityType[] toEntityTypes(string[] values)
  => values.map!toEntityType.array;

string toString(EntityType value)
  => value.to!string;

string[] toStrings(EntityType[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("EntityType"));

  assert("user".toEntityType == EntityType.user);
  assert("group".toEntityType == EntityType.group);

  assert("".toEntityType == EntityType.user);
  assert("unknown".toEntityType == EntityType.user);

  assert(EntityType.user.toString == "user");
  assert(EntityType.group.toString == "group");

  assert(["user", "group"].toEntityTypes == [
      EntityType.user, EntityType.group
    ]);
  assert([EntityType.user, EntityType.group].toStrings == ["user", "group"]);
}

/// Status of a provisioned entity in a target system.
enum EntityStatus {
  active, // Successfully provisioned and active in target system
  inactive, // Provisioned but currently inactive in target system
  pending, // Provisioning operation is pending or in progress
  error // Provisioning operation failed or entity is in error state in target system
}

EntityStatus toEntityStatus(string value) {
  mixin(EnumSwitch("EntityStatus", "active"));
}

EntityStatus[] toEntityStatuses(string[] values)
  => values.map!toEntityStatus.array;

string toString(EntityStatus value)
  => value.to!string;

string[] toStrings(EntityStatus[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("EntityStatus"));

  assert("active".toEntityStatus == EntityStatus.active);
  assert("inactive".toEntityStatus == EntityStatus.inactive);
  assert("pending".toEntityStatus == EntityStatus.pending);
  assert("error".toEntityStatus == EntityStatus.error);

  assert("".toEntityStatus == EntityStatus.active);
  assert("unknown".toEntityStatus == EntityStatus.active);

  assert(EntityStatus.active.toString == "active");
  assert(EntityStatus.inactive.toString == "inactive");
  assert(EntityStatus.pending.toString == "pending");
  assert(EntityStatus.error.toString == "error");

  assert(["active", "error"].toEntityStatuses == [
      EntityStatus.active, EntityStatus.error
    ]);
  assert([EntityStatus.active, EntityStatus.error].toStrings == ["active", "error"]);
}
