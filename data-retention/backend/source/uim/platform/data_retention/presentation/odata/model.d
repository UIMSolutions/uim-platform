/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the REST API,
/// the CLI and the GtkD GUI.
///
/// Scopes: Read (reads), Manage (writes, actions), Admin (Users).
/// Dates of the retention lifecycle are Edm.Date ("2026-01-31"), technical
/// timestamps Edm.DateTimeOffset.
module uim.platform.data_retention.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.dataretention";

/// Audit properties (all computed).
private ODataEntitySetDef audited(ODataEntitySetDef set) {
  return set.property("tenantId", Edm.string_, "Tenant")
    .property("createdAt", Edm.dateTimeOffset, "Created At")
    .property("createdBy", Edm.string_, "Created By")
    .property("updatedAt", Edm.dateTimeOffset, "Changed At")
    .property("updatedBy", Edm.string_, "Changed By")
    .computed("tenantId", "createdAt", "createdBy", "updatedAt", "updatedBy");
}

/// The derived retention evaluation of a data subject.
private ODataEntitySetDef evaluated(ODataEntitySetDef set) {
  return set.property("phase", Edm.string_, "Retention Phase")
    .property("governingLegalGroundId", Edm.string_, "Governing Legal Ground")
    .property("governingLegalGroundName", Edm.string_, "Governing Legal Ground Name")
    .property("residence", Edm.string_, "Residence")
    .property("retention", Edm.string_, "Retention")
    .property("endOfPurpose", Edm.date, "End of Purpose")
    .property("endOfRetention", Edm.date, "End of Retention")
    .property("actionOnExpiry", Edm.string_, "Action on Expiry")
    .property("daysToEndOfRetention", Edm.int32, "Days to End of Retention")
    .property("dueForBlocking", Edm.boolean, "Due for Blocking")
    .property("dueForDestruction", Edm.boolean, "Due for Destruction")
    .property("retentionReason", Edm.string_, "Evaluation")
    .computed("phase", "governingLegalGroundId", "governingLegalGroundName", "residence", "retention", "endOfPurpose",
      "endOfRetention", "actionOnExpiry", "daysToEndOfRetention", "dueForBlocking", "dueForDestruction", "retentionReason");
}

private ODataComplexTypeDef evaluationProperties(ODataComplexTypeDef t) {
  return t.property("phase", Edm.string_, "Retention Phase")
    .property("governingLegalGroundId", Edm.string_, "Governing Legal Ground")
    .property("governingLegalGroundName", Edm.string_, "Governing Legal Ground Name")
    .property("residence", Edm.string_, "Residence")
    .property("retention", Edm.string_, "Retention")
    .property("endOfPurpose", Edm.date, "End of Purpose")
    .property("endOfRetention", Edm.date, "End of Retention")
    .property("actionOnExpiry", Edm.string_, "Action on Expiry")
    .property("retentionReason", Edm.string_, "Evaluation");
}

ODataServiceModel dataRetentionModel() {
  auto m = new ODataServiceModel(odataNamespace, "DataRetentionService", "Data Retention");

  // ── master data ─────────────────────────────────────────────────────────
  audited(m.entitySet("ApplicationGroups", "ApplicationGroup")
      .property("id", Edm.string_, "Application Group", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("scope", Edm.string_, "Scope")
      .collection("applicationIds", Edm.string_, "Applications")
      .property("applicationsText", Edm.string_, "Applications")
      .property("active", Edm.boolean, "Active")
      .property("businessPurposeCount", Edm.int32, "Business Purposes")
      .property("dataSubjectCount", Edm.int32, "Data Subjects")
      .computed("applicationsText", "businessPurposeCount", "dataSubjectCount"))
    .writable()
    .titled("Application Group", "Application Groups", "name", "description")
    .columns("name", "id", "scope", "applicationsText", "active", "dataSubjectCount")
    .filters("scope", "active")
    .scopes(readScope, manageScope);

  audited(m.entitySet("LegalEntities", "LegalEntity")
      .property("id", Edm.string_, "Legal Entity", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("country", Edm.string_, "Country")
      .property("region", Edm.string_, "Region")
      .property("active", Edm.boolean, "Active"))
    .writable()
    .titled("Legal Entity", "Legal Entities", "name", "country")
    .columns("name", "id", "country", "region", "active")
    .filters("country", "region", "active")
    .scopes(readScope, manageScope);

  audited(m.entitySet("DataSubjectRoles", "DataSubjectRole")
      .property("id", Edm.string_, "Role", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("active", Edm.boolean, "Active"))
    .writable()
    .titled("Data Subject Role", "Data Subject Roles", "name", "description")
    .columns("name", "id", "description", "active")
    .filters("active")
    .scopes(readScope, manageScope);

  // ── purposes and rules ──────────────────────────────────────────────────
  audited(m.entitySet("BusinessPurposes", "BusinessPurpose")
      .property("id", Edm.string_, "Business Purpose", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("applicationGroupId", Edm.string_, "Application Group", false)
      .property("dataSubjectRoleId", Edm.string_, "Data Subject Role", false)
      .property("legalEntityId", Edm.string_, "Legal Entity")
      .property("status", Edm.string_, "Status")
      .property("activatedAt", Edm.dateTimeOffset, "Activated At")
      .property("legalGroundCount", Edm.int32, "Legal Grounds")
      .property("completeLegalGrounds", Edm.int32, "Legal Grounds with Rules")
      .property("dataSubjectCount", Edm.int32, "Data Subjects")
      .property("rulesText", Edm.string_, "Rules")
      .computed("status", "activatedAt", "legalGroundCount", "completeLegalGrounds", "dataSubjectCount", "rulesText"))
    .writable()
    .titled("Business Purpose", "Business Purposes", "name", "description")
    .columns("name", "id", "applicationGroupId", "dataSubjectRoleId", "status", "rulesText", "dataSubjectCount")
    .filters("applicationGroupId", "dataSubjectRoleId", "legalEntityId", "status")
    .scopes(readScope, manageScope);

  audited(m.entitySet("LegalGrounds", "LegalGround")
      .property("id", Edm.string_, "Legal Ground", false)
      .property("businessPurposeId", Edm.string_, "Business Purpose", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("type", Edm.string_, "Type")
      .property("legalReference", Edm.string_, "Legal Reference")
      .property("active", Edm.boolean, "Active")
      .property("residenceRuleId", Edm.string_, "Residence Rule")
      .property("residence", Edm.string_, "Residence")
      .property("retentionRuleId", Edm.string_, "Retention Rule")
      .property("retention", Edm.string_, "Retention")
      .property("actionOnExpiry", Edm.string_, "Action on Expiry")
      .computed("residenceRuleId", "residence", "retentionRuleId", "retention", "actionOnExpiry")
      .immutableProps("businessPurposeId"))
    .writable()
    .titled("Legal Ground", "Legal Grounds", "name", "legalReference")
    .columns("name", "businessPurposeId", "type", "legalReference", "residence", "retention", "actionOnExpiry", "active")
    .filters("businessPurposeId", "type", "active")
    .scopes(readScope, manageScope);

  audited(m.entitySet("ResidenceRules", "ResidenceRule")
      .property("id", Edm.string_, "Residence Rule", false)
      .property("businessPurposeId", Edm.string_, "Business Purpose")
      .property("legalGroundId", Edm.string_, "Legal Ground", false)
      .property("duration", Edm.int32, "Duration", false)
      .property("periodUnit", Edm.string_, "Unit")
      .property("periodText", Edm.string_, "Residence Period")
      .property("active", Edm.boolean, "Active")
      .computed("periodText")
      .immutableProps("businessPurposeId", "legalGroundId"))
    .writable()
    .titled("Residence Rule", "Residence Rules", "periodText", "legalGroundId")
    .columns("legalGroundId", "businessPurposeId", "periodText", "active")
    .filters("businessPurposeId", "legalGroundId", "active")
    .scopes(readScope, manageScope);

  audited(m.entitySet("RetentionRules", "RetentionRule")
      .property("id", Edm.string_, "Retention Rule", false)
      .property("businessPurposeId", Edm.string_, "Business Purpose")
      .property("legalGroundId", Edm.string_, "Legal Ground", false)
      .property("duration", Edm.int32, "Duration", false)
      .property("periodUnit", Edm.string_, "Unit")
      .property("periodText", Edm.string_, "Retention Period")
      .property("actionOnExpiry", Edm.string_, "Action on Expiry")
      .property("active", Edm.boolean, "Active")
      .computed("periodText")
      .immutableProps("businessPurposeId", "legalGroundId"))
    .writable()
    .titled("Retention Rule", "Retention Rules", "periodText", "legalGroundId")
    .columns("legalGroundId", "businessPurposeId", "periodText", "actionOnExpiry", "active")
    .filters("businessPurposeId", "legalGroundId", "actionOnExpiry", "active")
    .scopes(readScope, manageScope);

  // ── data subjects ───────────────────────────────────────────────────────
  audited(evaluated(m.entitySet("DataSubjects", "DataSubject")
      .property("id", Edm.string_, "Data Subject", false)
      .property("externalId", Edm.string_, "External ID", false)
      .property("displayName", Edm.string_, "Name")
      .property("applicationGroupId", Edm.string_, "Application Group")
      .property("dataSubjectRoleId", Edm.string_, "Role")
      .property("businessPurposeId", Edm.string_, "Business Purpose", false)
      .property("legalGroundId", Edm.string_, "Legal Ground")
      .property("legalEntityId", Edm.string_, "Legal Entity")
      .property("referenceDate", Edm.date, "Reference Date (End of Business)")
      .property("lifecycleStatus", Edm.string_, "Lifecycle Status")
      .property("legalHold", Edm.boolean, "Legal Hold")
      .property("legalHoldReason", Edm.string_, "Legal Hold Reason")
      .property("blockedAt", Edm.dateTimeOffset, "Blocked At")
      .property("archivedAt", Edm.dateTimeOffset, "Archived At")
      .property("markedForDeletionAt", Edm.dateTimeOffset, "Marked for Deletion At")
      .property("deletedAt", Edm.dateTimeOffset, "Destroyed At")
      .property("deletionMethod", Edm.string_, "Destruction Method")
      .computed("lifecycleStatus", "legalHold", "legalHoldReason", "blockedAt", "archivedAt", "markedForDeletionAt", "deletedAt",
        "deletionMethod")))
    .writable()
    .titled("Data Subject", "Data Subjects", "externalId", "displayName")
    .columns("externalId", "displayName", "businessPurposeId", "referenceDate", "lifecycleStatus", "phase", "endOfPurpose",
      "endOfRetention")
    .filters("applicationGroupId", "businessPurposeId", "lifecycleStatus", "phase", "legalHold")
    .scopes(readScope, manageScope);

  audited(m.entitySet("DeletionRequests", "DeletionRequest")
      .property("id", Edm.string_, "Deletion Request", false)
      .property("dataSubjectId", Edm.string_, "Data Subject", false)
      .property("applicationGroupId", Edm.string_, "Application Group")
      .property("action", Edm.string_, "Action")
      .property("status", Edm.string_, "Status")
      .property("reason", Edm.string_, "Reason")
      .property("processedAt", Edm.dateTimeOffset, "Processed At")
      .property("resultMessage", Edm.string_, "Result")
      .property("earliestDeletion", Edm.date, "Earliest Deletion")
      .computed("applicationGroupId", "status", "processedAt", "resultMessage", "earliestDeletion"))
    .writable(true, false, true)
    .titled("Deletion Request", "Deletion Requests", "dataSubjectId", "reason")
    .columns("dataSubjectId", "action", "status", "reason", "resultMessage", "processedAt")
    .filters("status", "action", "applicationGroupId", "dataSubjectId")
    .scopes(readScope, manageScope);

  audited(m.entitySet("ArchivingJobs", "ArchivingJob")
      .property("id", Edm.string_, "Archiving Job", false)
      .property("applicationGroupId", Edm.string_, "Application Group", false)
      .property("operation", Edm.string_, "Operation")
      .property("dryRun", Edm.boolean, "Dry Run")
      .property("referenceBefore", Edm.date, "Reference Date Before")
      .property("scheduledAt", Edm.dateTimeOffset, "Scheduled At")
      .property("status", Edm.string_, "Status")
      .property("startedAt", Edm.dateTimeOffset, "Started At")
      .property("completedAt", Edm.dateTimeOffset, "Completed At")
      .property("selected", Edm.int32, "Selected")
      .property("archived", Edm.int32, "Archived")
      .property("destroyed", Edm.int32, "Destroyed")
      .property("skipped", Edm.int32, "Skipped")
      .property("failed", Edm.int32, "Failed")
      .property("errorMessage", Edm.string_, "Error")
      .collection("log", Edm.string_, "Log")
      .property("logText", Edm.string_, "Log")
      .computed("status", "startedAt", "completedAt", "selected", "archived", "destroyed", "skipped", "failed", "errorMessage",
        "log", "logText"))
    .writable(true, false, true)
    .titled("Archiving Job", "Archiving Jobs", "id", "operation")
    .columns("id", "applicationGroupId", "operation", "dryRun", "status", "scheduledAt", "archived", "destroyed")
    .filters("applicationGroupId", "operation", "status")
    .scopes(readScope, manageScope);

  // ── users of the built-in login (Admin scope) ───────────────────────────
  audited(m.entitySet("Users", "User")
      .property("id", Edm.string_, "User", false)
      .property("displayName", Edm.string_, "Name")
      .property("password", Edm.string_, "Password")
      .collection("scopes", Edm.string_, "Scopes")
      .property("scopesText", Edm.string_, "Scopes")
      .property("locked", Edm.boolean, "Locked")
      .property("temporarilyLocked", Edm.boolean, "Temporarily Locked")
      .property("failedLogins", Edm.int32, "Failed Logins")
      .property("lastLoginAt", Edm.dateTimeOffset, "Last Login")
      .computed("scopesText", "temporarilyLocked", "failedLogins", "lastLoginAt"))
    .writable()
    .titled("User", "Users", "id", "displayName")
    .columns("id", "displayName", "scopes", "locked", "lastLoginAt")
    .filters("locked")
    .scopes(adminScope, adminScope);

  m.singletonSet("Statistics", "Statistic")
    .keyed("tenantId")
    .property("tenantId", Edm.string_, "Tenant", false)
    .property("applicationGroups", Edm.int32, "Application Groups")
    .property("legalEntities", Edm.int32, "Legal Entities")
    .property("dataSubjectRoles", Edm.int32, "Data Subject Roles")
    .property("businessPurposes", Edm.int32, "Business Purposes")
    .property("activeBusinessPurposes", Edm.int32, "Active Business Purposes")
    .property("legalGrounds", Edm.int32, "Legal Grounds")
    .property("residenceRules", Edm.int32, "Residence Rules")
    .property("retentionRules", Edm.int32, "Retention Rules")
    .property("dataSubjects", Edm.int32, "Data Subjects")
    .property("activeSubjects", Edm.int32, "Active")
    .property("blockedSubjects", Edm.int32, "Blocked")
    .property("archivedSubjects", Edm.int32, "Archived")
    .property("markedForDeletion", Edm.int32, "Marked for Deletion")
    .property("deletedSubjects", Edm.int32, "Destroyed")
    .property("legalHolds", Edm.int32, "Legal Holds")
    .property("dueForBlocking", Edm.int32, "Due for Blocking")
    .property("dueForDestruction", Edm.int32, "Due for Destruction")
    .property("noRuleSubjects", Edm.int32, "Without Rule")
    .property("pendingRequests", Edm.int32, "Pending Deletion Requests")
    .property("rejectedRequests", Edm.int32, "Rejected Deletion Requests")
    .property("scheduledJobs", Edm.int32, "Scheduled Jobs")
    .property("failedJobs", Edm.int32, "Failed Jobs")
    .property("nextEndOfRetention", Edm.date, "Next End of Retention")
    .property("computedAt", Edm.dateTimeOffset, "Computed At")
    .titled("Statistics", "Statistics")
    .scopes(readScope, "");

  // ── result types ────────────────────────────────────────────────────────
  m.complexType("EndOfPurposeCheckResult")
    .property("applicationGroupId", Edm.string_, "Application Group")
    .property("simulated", Edm.boolean, "Simulated")
    .property("checked", Edm.int32, "Checked")
    .property("noRule", Edm.int32, "Without Rule")
    .property("withinResidence", Edm.int32, "Within Residence")
    .property("withinRetention", Edm.int32, "Within Retention")
    .property("endOfRetention", Edm.int32, "End of Retention")
    .property("alreadyDeleted", Edm.int32, "Already Destroyed")
    .property("blocked", Edm.int32, "Blocked")
    .property("markedForDeletion", Edm.int32, "Marked for Deletion")
    .property("legalHolds", Edm.int32, "Legal Holds")
    .property("blockedSubjects", Edm.string_, "Blocked Data Subjects")
    .property("markedSubjects", Edm.string_, "Marked Data Subjects")
    .property("checkedAt", Edm.dateTimeOffset, "Checked At");

  evaluationProperties(m.complexType("RetentionSimulation")
      .property("businessPurposeId", Edm.string_, "Business Purpose")
      .property("referenceDate", Edm.date, "Reference Date"));

  m.complexType("SeedResult")
    .property("applicationGroups", Edm.int32, "Application Groups")
    .property("legalEntities", Edm.int32, "Legal Entities")
    .property("dataSubjectRoles", Edm.int32, "Data Subject Roles")
    .property("businessPurposes", Edm.int32, "Business Purposes")
    .property("legalGrounds", Edm.int32, "Legal Grounds")
    .property("residenceRules", Edm.int32, "Residence Rules")
    .property("retentionRules", Edm.int32, "Retention Rules")
    .property("dataSubjects", Edm.int32, "Data Subjects")
    .property("deletionRequests", Edm.int32, "Deletion Requests")
    .property("archivingJobs", Edm.int32, "Archiving Jobs");

  m.complexType("RunSummary")
    .property("started", Edm.int32, "Started")
    .property("completed", Edm.int32, "Completed")
    .property("rejected", Edm.int32, "Rejected")
    .property("failed", Edm.int32, "Failed");

  // ── actions ─────────────────────────────────────────────────────────────
  m.action("ActivateBusinessPurpose", "BusinessPurpose").parameter("id", Edm.string_, false)
    .labelled("Activate Business Purpose").requires(manageScope);
  m.action("DeactivateBusinessPurpose", "BusinessPurpose").parameter("id", Edm.string_, false)
    .labelled("Deactivate Business Purpose").requires(manageScope);
  m.action("DeprecateBusinessPurpose", "BusinessPurpose").parameter("id", Edm.string_, false)
    .labelled("Deprecate Business Purpose (no new data subjects)").requires(manageScope);
  m.action("BlockDataSubject", "DataSubject").parameter("id", Edm.string_, false)
    .labelled("Block Data Subject").requires(manageScope);
  m.action("SetLegalHold", "DataSubject").parameter("id", Edm.string_, false).parameter("legalHold", Edm.boolean, false)
    .parameter("reason", Edm.string_).labelled("Set / Release Legal Hold").requires(manageScope);
  m.action("CheckEndOfPurpose", "EndOfPurposeCheckResult").parameter("applicationGroupId", Edm.string_)
    .parameter("simulate", Edm.boolean).labelled("Check End of Purpose (block / mark for deletion)").requires(manageScope);
  m.action("SimulateRetention", "RetentionSimulation").parameter("businessPurposeId", Edm.string_, false)
    .parameter("referenceDate", Edm.date, false).parameter("legalGroundId", Edm.string_)
    .labelled("Simulate Retention (dates for a reference date)").requires(readScope);
  m.action("ProcessDeletionRequest", "DeletionRequest").parameter("id", Edm.string_, false)
    .labelled("Process Deletion Request").requires(manageScope);
  m.action("CancelDeletionRequest", "DeletionRequest").parameter("id", Edm.string_, false)
    .labelled("Cancel Deletion Request").requires(manageScope);
  m.action("ProcessPendingRequests", "RunSummary").labelled("Process all Pending Deletion Requests").requires(manageScope);
  m.action("RunArchivingJob", "ArchivingJob").parameter("id", Edm.string_, false)
    .labelled("Run Archiving Job now").requires(manageScope);
  m.action("CancelArchivingJob", "ArchivingJob").parameter("id", Edm.string_, false)
    .labelled("Cancel Archiving Job").requires(manageScope);
  m.action("RunDueJobs", "RunSummary").labelled("Run all Due Archiving Jobs").requires(manageScope);
  m.action("SeedDemoData", "SeedResult").labelled("Create Demo Content").requires(manageScope);

  m.validate();
  return m;
}

///
unittest {
  auto m = dataRetentionModel();
  assert(m.has("DataSubjects") && m.find("Statistics").singleton && m.find("DataSubjects").key == "id");
  assert(m.find("DeletionRequests").insertable && !m.find("DeletionRequests").updatable);
  assert(m.find("DataSubjects").propertyOf("phase").computed && m.find("LegalGrounds").propertyOf("businessPurposeId").immutable_);
  assert(m.findAction("CheckEndOfPurpose").returnEdmType == "uim.dataretention.EndOfPurposeCheckResult");
}
