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
  const map = [
    "ias": SystemType.ias,
    "ldap": SystemType.ldap,
    "sap_hr": SystemType.sap_hr,
    "scim": SystemType.scim,
    "csv": SystemType.csv,
    "azure_ad": SystemType.azure_ad,
    "custom": SystemType.custom
  ];
  return map.get(s.toLower, SystemType.custom);
}

/// Operational status of a system connection.
enum SystemStatus {
  active, // System connection is active and operational
  inactive, // System connection is inactive or disabled
  error, // System connection is in error state (e.g. failed connectivity tests)
  configuring // System connection is being configured or tested
}
SystemStatus toSystemStatus(string s) {
  const map = [
    "active": SystemStatus.active,
    "inactive": SystemStatus.inactive,
    "error": SystemStatus.error,
    "configuring": SystemStatus.configuring
  ];
  return map.get(s.toLower, SystemStatus.inactive);
}

/// Role of a system in the provisioning pipeline.
enum SystemRole {
  source, // System is a source of identity data (e.g. HR system)
  target, // System is a target for provisioning (e.g. cloud application)
  proxy // System acts as a proxy or middleware in the provisioning flow
}
SystemRole toSystemRole(string s) {
  const map = [
    "source": SystemRole.source,
    "target": SystemRole.target,
    "proxy": SystemRole.proxy
  ];
  return map.get(s.toLower, SystemRole.source);
}

/// Type of provisioning job.
enum JobType {
  full, // Full provisioning - all entities are provisioned regardless of previous state
  delta, // Delta provisioning - only entities that have changed since last successful run are provisioned
  simulate // Simulation mode - provisioning logic is executed but no actual changes are made to target systems
}
JobType toJobType(string s) {
  const map = [
    "full": JobType.full,
    "delta": JobType.delta,
    "simulate": JobType.simulate
  ];
  return map.get(s.toLower, JobType.full);
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
  const map = [
    "scheduled": JobStatus.scheduled,
    "running": JobStatus.running,
    "completed": JobStatus.completed,
    "failed": JobStatus.failed,
    "cancelled": JobStatus.cancelled
  ];
  return map.get(s.toLower, JobStatus.scheduled);
}

/// Type of provisioning operation on a single entity.
enum OperationType {
  create, // Create new entity in target system
  update, // Update existing entity in target system
  delete_, // Delete entity from target system 
  skip // Skip operation (e.g. due to filters or errors)
}
OperationType toOperationType(string s) {
  const map = [
    "create": OperationType.create,
    "update": OperationType.update,
    "delete": OperationType.delete_,
    "skip": OperationType.skip
  ];
  return map.get(s.toLower, OperationType.skip);
}

/// Outcome of a single provisioning operation.
enum LogStatus {
  success, // Operation completed successfully
  failed, // Operation failed
  skipped // Operation was skipped
}
LogStatus toLogStatus(string s) {
  const map = [
    "success": LogStatus.success,
    "failed": LogStatus.failed,
    "skipped": LogStatus.skipped
  ];
  return map.get(s.toLower, LogStatus.skipped);
}

/// Kind of identity entity being provisioned.
enum EntityType {
  user, // User entity
  group // Group or role entity
}
EntityType toEntityType(string s) {
  const map = [
    "user": EntityType.user,
    "group": EntityType.group
  ];
  return map.get(s.toLower, EntityType.user);
}

/// Status of a provisioned entity in a target system.
enum EntityStatus {
  active, // Successfully provisioned and active in target system
  inactive, // Provisioned but currently inactive in target system
  pending, // Provisioning operation is pending or in progress
  error // Provisioning operation failed or entity is in error state in target system
}
EntityStatus toEntityStatus(string s) {
  const map = [
    "active": EntityStatus.active,
    "inactive": EntityStatus.inactive,
    "pending": EntityStatus.pending,
    "error": EntityStatus.error
  ];
  return map.get(s.toLower, EntityStatus.pending);
}
