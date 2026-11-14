/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Demo landscape: an incident management application with APIs, the base
/// policies, two custom policies and assignments to users and a group.
module uim.platform.authorization.application.services.demo_data;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class DemoDataService : IDemoDataService {
  protected IManageApplications applications;
  protected IManageApplicationApis apis;
  protected IManagePolicies policies;
  protected IManageAssignments assignments;
  protected IEvaluateAuthorization evaluation;

  this(IManageApplications applications, IManageApplicationApis apis, IManagePolicies policies,
    IManageAssignments assignments, IEvaluateAuthorization evaluation) {
    this.applications = applications;
    this.apis = apis;
    this.policies = policies;
    this.assignments = assignments;
    this.evaluation = evaluation;
  }

  bool isEmpty(TenantId tenantId) {
    return applications.listApplications(tenantId).length == 0;
  }

  DemoDataResult seed(TenantId tenantId, UserId actor) {
    if (!isEmpty(tenantId))
      throw AuthorizationException.conflict("Tenant '" ~ tenantId.value ~ "' already has applications — nothing seeded");
    DemoDataResult r;

    CreateApplicationRequest app;
    app.tenantId = tenantId;
    app.actor = actor;
    app.name = "incident-management";
    app.organizationId = "global";
    app.description = "Incident management (demo application)";
    auto incidents = applications.createApplication(app);
    app.name = "sales-orders";
    app.description = "Sales order processing (demo application)";
    auto sales = applications.createApplication(app);
    r.applications = 2;

    ApplicationApi api(ManagedApplication owner, string name, string endpoint, string[] operations) {
      CreateApplicationApiRequest q;
      q.tenantId = tenantId;
      q.actor = actor;
      q.applicationId = owner.id;
      q.name = name;
      q.endpoint = endpoint;
      q.operations = operations;
      r.apis++;
      return apis.createApi(q);
    }

    api(incidents, "incidents", "/odata/v4/incidents/Incidents", ["Read", "Create", "Update", "Close"]);
    api(incidents, "customers", "/odata/v4/incidents/Customers", ["Read"]);
    api(sales, "orders", "/api/v1/orders", ["Read", "Create", "Approve"]);

    auto base = policies.seedBasePolicies(tenantId, incidents.id, actor);
    r.policies += base.length;
    r.policies += policies.seedBasePolicies(tenantId, sales.id, actor).length;

    AuthorizationPolicy custom(ManagedApplication owner, string name, string description, string resource,
      string action, string conditions) {
      CreatePolicyRequest q;
      q.tenantId = tenantId;
      q.actor = actor;
      q.applicationId = owner.id;
      q.name = name;
      q.description = description;
      q.resource = resource;
      q.action = action;
      q.conditions = parseConditions(conditions);
      r.policies++;
      return policies.createPolicy(q);
    }

    auto supportUs = custom(incidents, "support-us", "Support agents may read and update incidents of US customers",
      "Incident", "Read, Update", "country eq US");
    auto approver = custom(sales, "order-approver", "Approve orders up to 10,000 within the own sales organization",
      "Order", "Approve", "salesOrg in 1000,2000; amount le 10000");

    void assign(AuthorizationPolicy p, PrincipalType type, string principal) {
      CreateAssignmentRequest q;
      q.tenantId = tenantId;
      q.actor = actor;
      q.policyId = p.id;
      q.principalType = cast(string) type;
      q.principalId = principal;
      assignments.assignPolicy(q);
      r.assignments++;
    }

    auto admin = base.filter!(p => p.name == "admin").front;
    auto reader = base.filter!(p => p.name == "reader").front;
    assign(admin, PrincipalType.group, "Administrators");
    assign(reader, PrincipalType.user, "bob");
    assign(supportUs, PrincipalType.user, "alice");
    assign(supportUs, PrincipalType.group, "Support");
    assign(approver, PrincipalType.user, "carol");

    // two example checks for the decision log
    EvaluateAuthorizationRequest check;
    check.tenantId = tenantId;
    check.principalId = "alice";
    check.application = incidents.name;
    check.resource = "Incident";
    check.action = "Update";
    check.attributes = ["country": "US"];
    check.channel = "demo";
    evaluation.evaluate(check);
    check.attributes = ["country": "DE"];
    evaluation.evaluate(check);
    r.decisions = 2;
    return r;
  }
}
