/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.services.demo;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Creates a small, realistic landscape in an empty tenant (local development,
/// Fiori demo, `uim-ips-cli demo`): SuccessFactors and LDAP sources, an IAS and
/// a BTP target, a proxy, read/write transformations and two jobs — and runs
/// the first job once. Works through the driving ports only.
class DemoDataSeeder {
  protected ProvisioningPorts ports;

  this(ProvisioningPorts ports) {
    this.ports = ports;
  }

  /// False if the tenant already has systems.
  bool seed(TenantId tenantId, UserId actor = UserId("demo")) {
    if (ports.sourceSystems.list(tenantId).length > 0 || ports.targetSystems.list(tenantId).length > 0)
      return false;

    SystemSpec system(string name, SystemType type, string url, AuthenticationType auth, string user,
        Attribute[] properties, string description) {
      SystemSpec s;
      s.name = name;
      s.description = description;
      s.systemType = type;
      s.url = url;
      s.authenticationType = auth;
      s.user = user;
      s.password = "demo-secret";
      s.properties = properties;
      return s;
    }

    string ok(UsecaseResult r) {
      if (!r.isSuccess)
        throw new ProvisioningException("demo data: " ~ r.message, cast(int) r.code);
      return r.id;
    }

    auto sf = ok(ports.sourceSystems.create(CreateSystemRequest(tenantId, actor, system("SuccessFactors HR",
        SystemType.successFactors, "https://api4.successfactors.com/odata/v2", AuthenticationType.basic, "sfadmin@ACME",
        [Attribute("sim.users", "6"), Attribute("sim.groups", "3"), Attribute("sim.domain", "acme.com"),
        Attribute("sf.user.filter", "status in 't','f'")], "Employee Central — employees and departments"))));
    auto ldap = ok(ports.sourceSystems.create(CreateSystemRequest(tenantId, actor, system("Corporate LDAP",
        SystemType.ldap, "ldaps://ldap.acme.com:636", AuthenticationType.basic, "cn=reader,dc=acme,dc=com",
        [Attribute("sim.users", "8"), Attribute("sim.domain", "acme.com"),
        Attribute("ldap.user.filter", "(objectClass=inetOrgPerson)")], "On-premise directory via Cloud Connector"))));
    auto ias = ok(ports.targetSystems.create(CreateSystemRequest(tenantId, actor, system("Identity Authentication",
        SystemType.ias, "https://acme.accounts.ondemand.com", AuthenticationType.oauth2ClientCredentials,
        "ips-client", null, "Production IAS tenant"))));
    auto btp = ok(ports.targetSystems.create(CreateSystemRequest(tenantId, actor, system("BTP Subaccount",
        SystemType.scim, "https://api.authentication.eu10.hana.ondemand.com/scim/v2",
        AuthenticationType.oauth2ClientCredentials, "sb-ips", null, "Shadow users of the BTP subaccount"))));
    ok(ports.proxySystems.create(CreateSystemRequest(tenantId, actor, system("Identity Directory Proxy",
        SystemType.scim, "https://ips-proxy.acme.com/scim/v2", AuthenticationType.basic, "proxy",
        null, "SCIM proxy for the external identity management system"))));

    ok(ports.sourceSystems.activate(tenantId, SourceSystemId(sf), actor));
    ok(ports.sourceSystems.activate(tenantId, SourceSystemId(ldap), actor));
    ok(ports.targetSystems.activate(tenantId, TargetSystemId(ias), actor));
    ok(ports.targetSystems.activate(tenantId, TargetSystemId(btp), actor));

    TransformationSpec read;
    read.name = "SuccessFactors read";
    read.description = "Only employees with an employee number";
    read.systemRole = SystemRole.source;
    read.systemId = sf;
    read.scope_ = EntityScope.user;
    read.conditions = [EntityCondition("employeeNumber", ConditionOperator.present)];
    ok(ports.transformations.create(CreateTransformationRequest(tenantId, actor, read)));

    TransformationSpec users;
    users.name = "IAS users";
    users.description = "SCIM 2.0 user schema of Identity Authentication";
    users.systemRole = SystemRole.target;
    users.systemId = ias;
    users.scope_ = EntityScope.user;
    users.mappings = [
      AttributeMapping("userName", "userName", MappingFunction.lowerCase, "", true),
      AttributeMapping("email", "emails[0].value", MappingFunction.lowerCase, "", true),
      AttributeMapping("givenName", "name.givenName"),
      AttributeMapping("familyName", "name.familyName"),
      AttributeMapping("displayName", "displayName"),
      AttributeMapping("department", "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:department"),
      AttributeMapping("employeeNumber", "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:employeeNumber"),
      AttributeMapping("active", "active", MappingFunction.none, "true"),
      AttributeMapping("", "userType", MappingFunction.constant, "employee"),
    ];
    ok(ports.transformations.create(CreateTransformationRequest(tenantId, actor, users)));

    TransformationSpec groups;
    groups.name = "IAS groups";
    groups.systemRole = SystemRole.target;
    groups.systemId = ias;
    groups.scope_ = EntityScope.group;
    groups.sequence = 20;
    groups.mappings = [
      AttributeMapping("displayName", "displayName", MappingFunction.trim, "", true),
      AttributeMapping("members", "members"),
      AttributeMapping("description", "urn:sap:cloud:scim:schemas:extension:custom:2.0:Group:description"),
    ];
    ok(ports.transformations.create(CreateTransformationRequest(tenantId, actor, groups)));

    JobSpec hourly;
    hourly.description = "Hourly delta synchronisation of all employees";
    hourly.sourceSystemId = SourceSystemId(sf);
    hourly.targetSystemId = TargetSystemId(ias);
    hourly.jobType = JobType.delta;
    hourly.intervalMinutes = 60;
    auto job = ok(ports.jobs.create(CreateJobRequest(tenantId, actor, hourly)));

    JobSpec ondemand;
    ondemand.description = "Full load of the directory into the subaccount (on demand)";
    ondemand.sourceSystemId = SourceSystemId(ldap);
    ondemand.targetSystemId = TargetSystemId(btp);
    ondemand.jobType = JobType.full;
    ok(ports.jobs.create(CreateJobRequest(tenantId, actor, ondemand)));

    ok(ports.jobs.run(tenantId, ProvisioningJobId(job), actor));
    return true;
  }
}
