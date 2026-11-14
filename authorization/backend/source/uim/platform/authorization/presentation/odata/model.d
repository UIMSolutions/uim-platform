/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the JSON API,
/// the vibe.d REST interface, the CLI and the GtkD GUI.
///
/// Scopes: Read (all reads), Admin (all changes, admin actions),
///         Check (EvaluateAuthorization — runtime checks of applications).
module uim.platform.authorization.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.authorization";

ODataServiceModel authorizationModel() {
  auto m = new ODataServiceModel(odataNamespace, "AuthorizationService", "Authorization Management");

  m.entitySet("Applications", "Application")
    .tenantAware()
    .property("name", Edm.string_, "Name", false)
    .property("organizationId", Edm.string_, "Organization")
    .property("description", Edm.string_, "Description")
    .property("apiCount", Edm.int32, "APIs")
    .property("policyCount", Edm.int32, "Policies")
    .computed("apiCount", "policyCount")
    .writable()
    .titled("Application", "Applications", "name", "description")
    .columns("name", "organizationId", "apiCount", "policyCount", "description")
    .filters("name", "organizationId")
    .scopes("Read", "Admin");

  m.entitySet("ApplicationApis", "ApplicationApi")
    .tenantAware()
    .property("applicationId", Edm.string_, "Application", false)
    .property("applicationName", Edm.string_, "Application Name")
    .property("name", Edm.string_, "Name", false)
    .property("endpoint", Edm.string_, "Endpoint", false)
    .collection("operations", Edm.string_, "Operations")
    .computed("applicationName")
    .immutableProps("applicationId")
    .writable()
    .titled("Application API", "Application APIs", "name", "endpoint")
    .columns("name", "applicationName", "endpoint")
    .filters("applicationId", "name")
    .scopes("Read", "Admin");

  m.entitySet("Policies", "Policy")
    .tenantAware()
    .property("applicationId", Edm.string_, "Application", false)
    .property("applicationName", Edm.string_, "Application Name")
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("resource", Edm.string_, "Resource", false)
    .property("action", Edm.string_, "Action", false)
    .property("conditions", Edm.string_, "Conditions")
    .property("kind", Edm.string_, "Kind")
    .property("status", Edm.string_, "Status")
    .property("assignmentCount", Edm.int32, "Assignments")
    .computed("applicationName", "assignmentCount")
    .immutableProps("applicationId", "kind")
    .writable()
    .titled("Policy", "Policies", "name", "description")
    .columns("name", "applicationName", "resource", "action", "conditions", "kind", "status", "assignmentCount")
    .filters("applicationId", "kind", "status", "resource")
    .scopes("Read", "Admin");

  m.entitySet("Assignments", "Assignment")
    .tenantAware()
    .property("policyId", Edm.string_, "Policy", false)
    .property("policyName", Edm.string_, "Policy Name")
    .property("applicationId", Edm.string_, "Application")
    .property("applicationName", Edm.string_, "Application Name")
    .property("principalType", Edm.string_, "Principal Type")
    .property("principalId", Edm.string_, "Principal", false)
    .property("validFrom", Edm.dateTimeOffset, "Valid From")
    .property("validTo", Edm.dateTimeOffset, "Valid To")
    .property("effective", Edm.boolean, "Effective")
    .computed("policyName", "applicationId", "applicationName", "effective")
    .immutableProps("policyId", "principalType", "principalId")
    .writable()
    .titled("Assignment", "Assignments", "principalId", "policyName")
    .columns("principalType", "principalId", "policyName", "applicationName", "validTo", "effective")
    .filters("principalType", "principalId", "policyId", "applicationId")
    .scopes("Read", "Admin");

  m.entitySet("Decisions", "Decision")
    .tenantAware()
    .property("principalId", Edm.string_, "Principal")
    .property("groups", Edm.string_, "Groups")
    .property("applicationId", Edm.string_, "Application")
    .property("applicationName", Edm.string_, "Application Name")
    .property("resource", Edm.string_, "Resource")
    .property("action", Edm.string_, "Action")
    .property("attributes", Edm.string_, "Attributes")
    .property("allowed", Edm.boolean, "Allowed")
    .property("reason", Edm.string_, "Reason")
    .property("matchedPolicies", Edm.string_, "Matched Policies")
    .property("channel", Edm.string_, "Channel")
    .writable(false, false, false)
    .titled("Decision", "Decisions", "principalId", "reason")
    .columns("createdAt", "principalId", "applicationName", "resource", "action", "allowed", "reason")
    .filters("principalId", "applicationId", "allowed", "channel")
    .scopes("Read", "");

  m.singletonSet("Statistics", "Statistic")
    .keyed("tenantId")
    .property("tenantId", Edm.string_, "Tenant", false)
    .property("applications", Edm.int32, "Applications")
    .property("applicationApis", Edm.int32, "Application APIs")
    .property("policies", Edm.int32, "Policies")
    .property("basePolicies", Edm.int32, "Base Policies")
    .property("customPolicies", Edm.int32, "Custom Policies")
    .property("disabledPolicies", Edm.int32, "Disabled Policies")
    .property("unassignedPolicies", Edm.int32, "Unassigned Policies")
    .property("assignments", Edm.int32, "Assignments")
    .property("userAssignments", Edm.int32, "User Assignments")
    .property("groupAssignments", Edm.int32, "Group Assignments")
    .property("expiredAssignments", Edm.int32, "Expired Assignments")
    .property("principals", Edm.int32, "Principals")
    .property("decisions", Edm.int32, "Decisions")
    .property("permittedDecisions", Edm.int32, "Permitted")
    .property("deniedDecisions", Edm.int32, "Denied")
    .property("lastDecisionAt", Edm.dateTimeOffset, "Last Decision")
    .titled("Statistic", "Statistics", "tenantId")
    .scopes("Read", "");

  m.complexType("AuthorizationResult")
    .property("allowed", Edm.boolean, "Allowed")
    .property("reason", Edm.string_, "Reason")
    .property("principalId", Edm.string_, "Principal")
    .property("applicationId", Edm.string_, "Application")
    .property("resource", Edm.string_, "Resource")
    .property("action", Edm.string_, "Action")
    .property("matchedPolicies", Edm.string_, "Matched Policies")
    .property("matchedPolicyIds", Edm.string_, "Matched Policy IDs")
    .property("candidatePolicies", Edm.int32, "Assigned Policies")
    .property("decisionId", Edm.string_, "Decision")
    .property("evaluatedAt", Edm.dateTimeOffset, "Evaluated At");
  m.action("EvaluateAuthorization", "AuthorizationResult")
    .parameter("principalId", Edm.string_, false)
    .parameter("application", Edm.string_, false)
    .parameter("resource", Edm.string_, false)
    .parameter("action", Edm.string_, false)
    .parameter("groups", Edm.string_)
    .parameter("attributes", Edm.string_)
    .parameter("record", Edm.boolean)
    .labelled("Check whether a principal may perform an action (groups: 'A, B'; attributes: 'country=US, level=3')")
    .requires("Check");

  m.complexType("ActionResult")
    .property("id", Edm.string_, "ID")
    .property("success", Edm.boolean, "Success")
    .property("message", Edm.string_, "Message")
    .property("count", Edm.int32, "Count");
  m.action("SeedBasePolicies", "ActionResult")
    .parameter("application", Edm.string_, false)
    .labelled("Create the missing base policies (admin, reader, support) of an application")
    .requires("Admin");
  m.action("EnablePolicy", "ActionResult")
    .parameter("id", Edm.string_, false)
    .labelled("Activate a disabled policy")
    .requires("Admin");
  m.action("DisablePolicy", "ActionResult")
    .parameter("id", Edm.string_, false)
    .labelled("Disable a policy (it stays assigned but grants nothing)")
    .requires("Admin");
  m.action("PruneDecisions", "ActionResult")
    .parameter("olderThanDays", Edm.int32, false)
    .labelled("Remove decision log entries older than N days")
    .requires("Admin");
  m.action("SeedDemoData", "ActionResult")
    .labelled("Load the demo applications, policies and assignments into an empty tenant")
    .requires("Admin");
  return m;
}

///
unittest {
  mixin(ShowTest!("authorizationModel"));

  auto m = authorizationModel();
  m.validate();
  assert(m.find("Policies") !is null && m.find("Statistics").singleton);
  assert(!m.find("Decisions").insertable && !m.find("Decisions").deletable);
  assert(m.findAction("EvaluateAuthorization").scope_ == "Check");
}
