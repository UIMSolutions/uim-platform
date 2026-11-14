/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line driving adapter. Talks to the application exclusively via the
/// driving ports (IdentityPorts) — exactly like the HTTP / OData / GUI adapters.
module uim.platform.identity_authentication.presentation.cli.commands;

import uim.platform.identity_authentication;
import uim.platform.identity_authentication.presentation.cli.args;
import uim.platform.identity_authentication.presentation.tabular;

mixin(ShowModule!());

@safe:

enum cliUsage = `uim-ias-cli — Identity Authentication administration

Usage: uim-ias-cli <resource> <command> [arguments] [options]

Global options:
  --tenant=<id>        tenant (default: configured defaultTenant)
  --as=<id>            acting user recorded in createdBy / updatedBy (default: cli)
  --data-dir=<dir>     snapshot directory shared with server and GUI
  --storage=memory     use volatile storage (testing)
  --json               machine readable JSON output

General:
  stats                                   tenant figures
  config                                  effective configuration (secrets masked)

Authentication (test the flows end to end):
  login --email=E|--user-name=U --password=P [--mfa=CODE] [--app=ID] [--ip=ADDR]
  logout <sessionId>
  token --session=ID --client-id=C --client-secret=S [--scopes=openid,profile]
  refresh --refresh-token=T --client-id=C --client-secret=S
  introspect <token>    userinfo <accessToken>    revoke-token <token>

Users:
  users list [--status=S] [--group=ID] | get <id|email|userName> | delete <id> | sessions <id>
  users create --email=E --password=P [--user-name=U] [--first-name=F] [--last-name=L] [--phone=N]
  users update <id> [--email= --user-name= --first-name= --last-name= --phone= --status=]
  users status <id> <active|inactive|locked|pendingVerification>
  users lock|unlock|deactivate <id>
  users password <id> --old=P --new=P        users reset-password <id> --new=P
  users mfa <id> <totp|sms|email>            users mfa-disable <id>

Groups:
  groups list | get <id> | delete <id> | members <id>
  groups create --name=N [--description=D]  |  update <id> [same]
  groups add-member|remove-member <groupId> <userId>

Applications (OAuth clients / service providers):
  apps list | get <id> | delete <id> | rotate-secret <id>
  apps create --name=N [--protocol=oidc|saml] [--redirect-uris=a,b] [--scopes=openid,profile]
              [--description=D] [--saml-entity-id=ID] [--saml-acs-url=URL] [--inactive]
  apps update <id> [same options, --active]

Authorization policies (rules: attribute:operator:value; attributes group, ip_range,
auth_method, mfa, user_status; operators eq, ne, in, not_in):
  policies list [--app=ID] | get <id> | delete <id>
  policies create --name=N --rules="group:in:admins; ip_range:in:10.0.0.0/8" [--apps=a,b] [--inactive]
  policies update <id> [same options, --active]
  policies evaluate --app=ID --user=ID [--ip=ADDR] [--auth-method=form] [--mfa]

Risk rules (conditions: ip_range, group, auth_method, failed_logins, user_agent):
  risk-rules list | get <id> | delete <id>
  risk-rules create --name=N --conditions="ip_range:not_in:10.0.0.0/8" [--level=low|medium|high|critical]
                    [--mfa-type=totp|sms|email] [--deny] [--inactive]
  risk-rules update <id> [same options, --active]
  risk-rules assess --user=ID [--ip=ADDR] [--user-agent=UA]

Corporate identity providers:
  idps list | get <id> | delete <id> | resolve <email> [--redirect-uri=URL] [--state=S]
  idps create --name=N --type=oidc|saml|ldap|corporate [--authorization-endpoint=URL]
              [--token-endpoint=URL] [--userinfo-endpoint=URL] [--metadata-url=URL]
              [--client-id=ID] [--client-secret=S] [--domains=a.com,b.com] [--default] [--inactive]
  idps update <id> [same options, --active]

Sessions and tokens:
  sessions list [--user=ID] [--active] | get <id> | revoke <id> | revoke-user <userId> | purge
  tokens list [--user=ID] | get <id> | revoke <id> | purge

  help
`;

/// Option → payload key maps of the create / update commands.
private enum string[2][] userOptions = [
    ["email", "email"], ["user-name", "userName"], ["first-name", "firstName"], ["last-name", "lastName"],
    ["phone", "phoneNumber"], ["password", "password"], ["status", "status"], ["external-idp", "externalIdpId"]
  ];
private enum string[2][] groupOptions = [["name", "name"], ["description", "description"]];
private enum string[2][] appOptions = [
    ["name", "name"], ["description", "description"], ["protocol", "protocol"],
    ["redirect-uris", "redirectUris"], ["scopes", "allowedScopes"], ["saml-entity-id", "samlEntityId"],
    ["saml-acs-url", "samlAcsUrl"], ["saml-metadata-url", "samlMetadataUrl"]
  ];
private enum string[2][] policyOptions = [
    ["name", "name"], ["description", "description"], ["rules", "rules"], ["apps", "applicationIds"]
  ];
private enum string[2][] riskRuleOptions = [
    ["name", "name"], ["conditions", "conditions"], ["level", "riskLevel"], ["mfa-type", "requiredMfa"],
    ["deny", "denyAccess"]
  ];
private enum string[2][] idpOptions = [
    ["name", "name"], ["type", "idpType"], ["metadata-url", "metadataUrl"],
    ["authorization-endpoint", "authorizationEndpoint"], ["token-endpoint", "tokenEndpoint"],
    ["userinfo-endpoint", "userInfoEndpoint"], ["client-id", "clientId"], ["client-secret", "clientSecret"],
    ["domains", "domainHints"], ["default", "isDefault"]
  ];

/// The command line adapter.
class IdentityCli {
  protected IdentityPorts ports;
  protected IdentityConfig config;
  protected void delegate(string) @safe output;
  protected TenantId tenant;
  protected UserId actor;
  protected bool json;

  this(IdentityPorts ports, IdentityConfig config, void delegate(string) @safe output) {
    this.ports = ports;
    this.config = config;
    this.output = output;
  }

  /// Run one command. Returns the process exit code (0 ok, 1 failure, 2 usage).
  int run(const string[] argv) {
    auto a = CliArgs.parse(argv);
    tenant = TenantId(a.opt("tenant", config.defaultTenant));
    actor = UserId(a.opt("as", "cli"));
    json = a.flag("json");

    try {
      if (a.positional.length == 0 || a.flag("help") || a.arg(0) == "help") {
        output(cliUsage);
        return a.positional.length == 0 && !a.flag("help") ? 2 : 0;
      }
      switch (a.arg(0)) {
      case "stats":
        auto s = ports.statistics.statistics(tenant);
        return emit(s.toJson, statisticsTable(s).render);
      case "config":
        return emit(config.toJson, config.toJson.toPrettyString ~ "\n");
      case "login":
        return login(a);
      case "logout":
        return emitResult(ports.authentication.logout(tenant, SessionId(a.requireArg(1, "session id"))));
      case "token":
        return token(a);
      case "refresh":
        RefreshRequest rr;
        rr.tenantId = tenant;
        rr.refreshToken = a.requireOpt("refresh-token");
        rr.clientId = a.requireOpt("client-id");
        rr.clientSecret = a.requireOpt("client-secret");
        rr.scopes = a.listOpt("scopes");
        return emitToken(ports.tokens.refreshTokens(rr));
      case "introspect":
        auto info = ports.tokens.introspect(tenant, a.requireArg(1, "token")).toJson;
        return emit(info, info.toPrettyString ~ "\n");
      case "userinfo":
        auto info = ports.tokens.userInfo(tenant, a.requireArg(1, "access token"));
        if (info.type == Json.Type.null_) {
          output("error: the access token is not active\n");
          return 1;
        }
        return emit(info, info.toPrettyString ~ "\n");
      case "revoke-token":
        return emitResult(ports.tokens.revoke(tenant, a.requireArg(1, "token")));
      case "users":
        return users(a);
      case "groups":
        return groups(a);
      case "apps", "applications":
        return applications(a);
      case "policies":
        return policies(a);
      case "risk-rules":
        return riskRules(a);
      case "idps", "identity-providers":
        return identityProviders(a);
      case "sessions":
        return sessions(a);
      case "tokens":
        return tokens(a);
      default:
        throw new CliUsageError("unknown resource '" ~ a.arg(0) ~ "'");
      }
    } catch (CliUsageError e) {
      output("error: " ~ e.msg ~ "\nRun 'uim-ias-cli help' for usage.\n");
      return 2;
    } catch (PayloadException e) {
      output("error: " ~ e.msg ~ "\n");
      return 2;
    } catch (Exception e) {
      output("error: " ~ e.msg ~ "\n");
      return 1;
    }
  }

  // ── authentication ─────────────────────────────────────────────────────

  protected int login(const CliArgs a) {
    AuthRequest req;
    req.tenantId = tenant;
    req.email = a.has("email") ? a.opt("email") : a.requireOpt("user-name");
    req.password = a.requireOpt("password");
    req.mfaCode = a.opt("mfa");
    req.applicationId = ApplicationId(a.opt("app"));
    req.ipAddress = a.opt("ip", "127.0.0.1");
    req.userAgent = "uim-ias-cli";
    auto r = ports.authentication.login(req);
    if (json)
      output(r.toJson.toPrettyString ~ "\n");
    else if (r.success)
      output("Authenticated — session %s (risk %s), expires %s\n".format(r.sessionId, enumValue(r.riskLevel),
          formatCliTime(r.expiresAt)));
    else if (r.mfaRequired)
      output("A %s one-time code is required — repeat with --mfa=CODE\n".format(enumValue(r.mfaType)));
    else
      output("error: " ~ r.message ~ "\n");
    return r.success ? 0 : 1;
  }

  protected int token(const CliArgs a) {
    TokenRequest req;
    req.tenantId = tenant;
    req.sessionId = SessionId(a.requireOpt("session"));
    req.clientId = a.requireOpt("client-id");
    req.clientSecret = a.requireOpt("client-secret");
    req.scopes = a.listOpt("scopes");
    req.ipAddress = a.opt("ip");
    return emitToken(ports.tokens.issueTokens(req));
  }

  // ── resources ──────────────────────────────────────────────────────────

  protected int users(const CliArgs a) {
    auto p = ports.users;
    switch (command(a)) {
    case "list":
      auto items = p.listUsers(tenant);
      if (a.has("status"))
        items = items.filter!(e => enumValue(e.status) == a.opt("status")).array;
      if (a.has("group"))
        items = items.filter!(e => e.isMemberOf(GroupId(a.opt("group")))).array;
      return emitTable(items, userTable(items));
    case "get":
      return emitOne(userOf(a.requireArg(2, "id, e-mail or user name")));
    case "create":
      UserDTO dto;
      readPayload(dto, body(a, userOptions));
      dto.tenantId = tenant;
      dto.createdBy = actor;
      return emitResult(p.createUser(dto));
    case "update":
      auto dto = UserDTO.fromEntity(userOf(a.requireArg(2, "id")));
      readPayload(dto, body(a, userOptions));
      dto.password = "";
      dto.updatedBy = actor;
      return emitResult(p.updateUser(dto));
    case "status":
      return emitResult(p.setUserStatus(tenant, userOf(a.requireArg(2, "id")).id, enumArg!UserStatus(a, 3), actor));
    case "lock":
      return emitResult(p.setUserStatus(tenant, userOf(a.requireArg(2, "id")).id, UserStatus.locked, actor));
    case "unlock":
      return emitResult(p.setUserStatus(tenant, userOf(a.requireArg(2, "id")).id, UserStatus.active, actor));
    case "deactivate":
      return emitResult(p.setUserStatus(tenant, userOf(a.requireArg(2, "id")).id, UserStatus.inactive, actor));
    case "password":
      ChangePasswordRequest req;
      req.tenantId = tenant;
      req.userId = userOf(a.requireArg(2, "id")).id;
      req.oldPassword = a.requireOpt("old");
      req.newPassword = a.requireOpt("new");
      return emitResult(p.changePassword(req));
    case "reset-password":
      return emitResult(p.resetPassword(tenant, userOf(a.requireArg(2, "id")).id, a.requireOpt("new"), actor));
    case "mfa":
      return emitResult(p.enrollMfa(tenant, userOf(a.requireArg(2, "id")).id, enumArg!MfaType(a, 3), actor));
    case "mfa-disable":
      return emitResult(p.disableMfa(tenant, userOf(a.requireArg(2, "id")).id, actor));
    case "sessions":
      auto items = ports.sessions.listByUser(tenant, userOf(a.requireArg(2, "id")).id);
      return emitTable(items, sessionTable(items));
    case "delete":
      return emitResult(p.deleteUser(tenant, userOf(a.requireArg(2, "id")).id));
    default:
      return unknown(a);
    }
  }

  protected int groups(const CliArgs a) {
    auto p = ports.groups;
    switch (command(a)) {
    case "list":
      auto items = p.listGroups(tenant);
      return emitTable(items, groupTable(items));
    case "get":
      return emitOne(found(p.getGroup(tenant, GroupId(a.requireArg(2, "id")))));
    case "members":
      auto items = p.listMembers(tenant, GroupId(a.requireArg(2, "id")));
      return emitTable(items, userTable(items));
    case "create":
      GroupDTO dto;
      readPayload(dto, body(a, groupOptions));
      dto.tenantId = tenant;
      dto.createdBy = actor;
      return emitResult(p.createGroup(dto));
    case "update":
      auto dto = GroupDTO.fromEntity(found(p.getGroup(tenant, GroupId(a.requireArg(2, "id")))));
      readPayload(dto, body(a, groupOptions));
      dto.updatedBy = actor;
      return emitResult(p.updateGroup(dto));
    case "add-member":
      return emitResult(p.addMember(tenant, GroupId(a.requireArg(2, "group id")), userOf(a.requireArg(3, "user")).id));
    case "remove-member":
      return emitResult(p.removeMember(tenant, GroupId(a.requireArg(2, "group id")), userOf(a.requireArg(3, "user")).id));
    case "delete":
      return emitResult(p.deleteGroup(tenant, GroupId(a.requireArg(2, "id"))));
    default:
      return unknown(a);
    }
  }

  protected int applications(const CliArgs a) {
    auto p = ports.applications;
    switch (command(a)) {
    case "list":
      auto items = p.listApplications(tenant);
      return emitTable(items, applicationTable(items));
    case "get":
      return emitOne(found(p.getApplication(tenant, ApplicationId(a.requireArg(2, "id")))));
    case "create":
      ApplicationDTO dto;
      readPayload(dto, withActive(a, body(a, appOptions)));
      dto.tenantId = tenant;
      dto.createdBy = actor;
      return emitResult(p.createApplication(dto));
    case "update":
      auto dto = ApplicationDTO.fromEntity(found(p.getApplication(tenant, ApplicationId(a.requireArg(2, "id")))));
      readPayload(dto, withActive(a, body(a, appOptions)));
      dto.updatedBy = actor;
      return emitResult(p.updateApplication(dto));
    case "rotate-secret":
      return emitResult(p.rotateClientSecret(tenant, ApplicationId(a.requireArg(2, "id")), actor));
    case "delete":
      return emitResult(p.deleteApplication(tenant, ApplicationId(a.requireArg(2, "id"))));
    default:
      return unknown(a);
    }
  }

  protected int policies(const CliArgs a) {
    auto p = ports.policies;
    switch (command(a)) {
    case "list":
      auto items = a.has("app") ? p.listByApplication(tenant, ApplicationId(a.opt("app"))) : p.listPolicies(tenant);
      return emitTable(items, policyTable(items));
    case "get":
      return emitOne(found(p.getPolicy(tenant, PolicyId(a.requireArg(2, "id")))));
    case "create":
      PolicyDTO dto;
      readPayload(dto, withActive(a, body(a, policyOptions)));
      dto.tenantId = tenant;
      dto.createdBy = actor;
      return emitResult(p.createPolicy(dto));
    case "update":
      auto dto = PolicyDTO.fromEntity(found(p.getPolicy(tenant, PolicyId(a.requireArg(2, "id")))));
      readPayload(dto, withActive(a, body(a, policyOptions)));
      dto.updatedBy = actor;
      return emitResult(p.updatePolicy(dto));
    case "evaluate":
      PolicyEvaluationContext ctx;
      ctx.ipAddress = a.opt("ip");
      ctx.authMethod = parseEnum!AuthMethod(a.opt("auth-method"), AuthMethod.form);
      ctx.mfaUsed = a.flag("mfa");
      auto r = p.evaluateAccess(tenant, ApplicationId(a.requireOpt("app")), userOf(a.requireOpt("user")).id, ctx);
      if (!json && r.isSuccess && r.data["denyingPolicies"].length > 0)
        output("Denied by: " ~ fieldStrings(r.data, "denyingPolicies").join(", ") ~ "\n");
      return emitResult(r);
    case "delete":
      return emitResult(p.deletePolicy(tenant, PolicyId(a.requireArg(2, "id"))));
    default:
      return unknown(a);
    }
  }

  protected int riskRules(const CliArgs a) {
    auto p = ports.riskRules;
    switch (command(a)) {
    case "list":
      auto items = p.listRiskRules(tenant);
      return emitTable(items, riskRuleTable(items));
    case "get":
      return emitOne(found(p.getRiskRule(tenant, RiskRuleId(a.requireArg(2, "id")))));
    case "create":
      RiskRuleDTO dto;
      readPayload(dto, withActive(a, body(a, riskRuleOptions)));
      dto.tenantId = tenant;
      dto.createdBy = actor;
      return emitResult(p.createRiskRule(dto));
    case "update":
      auto dto = RiskRuleDTO.fromEntity(found(p.getRiskRule(tenant, RiskRuleId(a.requireArg(2, "id")))));
      readPayload(dto, withActive(a, body(a, riskRuleOptions)));
      dto.updatedBy = actor;
      return emitResult(p.updateRiskRule(dto));
    case "assess":
      RiskEvaluationContext ctx;
      ctx.ipAddress = a.opt("ip");
      ctx.userAgent = a.opt("user-agent");
      auto r = p.assess(tenant, userOf(a.requireOpt("user")).id, ctx);
      if (!json && r.isSuccess)
        output("Risk %s · MFA %s · denied %s · triggered: %s\n".format(fieldString(r.data, "riskLevel"),
            fieldString(r.data, "requiredMfa"), fieldBool(r.data, "denied") ? "yes" : "no",
            fieldStrings(r.data, "triggeredRules").join(", ")));
      return emitResult(r);
    case "delete":
      return emitResult(p.deleteRiskRule(tenant, RiskRuleId(a.requireArg(2, "id"))));
    default:
      return unknown(a);
    }
  }

  protected int identityProviders(const CliArgs a) {
    auto p = ports.identityProviders;
    switch (command(a)) {
    case "list":
      auto items = p.listIdps(tenant);
      return emitTable(items, identityProviderTable(items));
    case "get":
      return emitOne(found(p.getIdp(tenant, IdpConfigId(a.requireArg(2, "id")))));
    case "create":
      IdpConfigDTO dto;
      readPayload(dto, withActive(a, body(a, idpOptions)));
      dto.tenantId = tenant;
      dto.createdBy = actor;
      return emitResult(p.createIdp(dto));
    case "update":
      auto dto = IdpConfigDTO.fromEntity(found(p.getIdp(tenant, IdpConfigId(a.requireArg(2, "id")))));
      readPayload(dto, withActive(a, body(a, idpOptions)));
      dto.updatedBy = actor;
      return emitResult(p.updateIdp(dto));
    case "resolve":
      auto email = a.requireArg(2, "e-mail");
      auto idp = found(p.resolveIdp(tenant, email));
      auto data = idp.toJson;
      if (a.has("redirect-uri"))
        data["authorizationUrl"] = p.buildAuthorizationUrl(idp, a.opt("redirect-uri"), a.opt("state", generateId));
      return emit(data, "%s → %s (%s)\n%s".format(email, idp.name, enumValue(idp.idpType),
          a.has("redirect-uri") ? data["authorizationUrl"].get!string ~ "\n" : ""));
    case "delete":
      return emitResult(p.deleteIdp(tenant, IdpConfigId(a.requireArg(2, "id"))));
    default:
      return unknown(a);
    }
  }

  protected int sessions(const CliArgs a) {
    auto p = ports.sessions;
    switch (command(a)) {
    case "list":
      auto items = a.has("user") ? p.listByUser(tenant, userOf(a.opt("user")).id)
        : a.flag("active") ? p.listActiveSessions(tenant) : p.listSessions(tenant);
      return emitTable(items, sessionTable(items));
    case "get":
      return emitOne(found(p.getSession(tenant, SessionId(a.requireArg(2, "id")))));
    case "revoke":
      return emitResult(p.revokeSession(tenant, SessionId(a.requireArg(2, "id"))));
    case "revoke-user":
      return emitResult(p.revokeAllForUser(tenant, userOf(a.requireArg(2, "user")).id));
    case "purge":
      return emitResult(p.purgeExpired(tenant));
    default:
      return unknown(a);
    }
  }

  protected int tokens(const CliArgs a) {
    auto p = ports.tokens;
    switch (command(a)) {
    case "list":
      auto items = a.has("user") ? p.listByUser(tenant, userOf(a.opt("user")).id) : p.listTokens(tenant);
      return emitTable(items, tokenTable(items));
    case "get":
      return emitOne(found(p.getToken(tenant, TokenId(a.requireArg(2, "id")))));
    case "revoke":
      return emitResult(p.revokeToken(tenant, TokenId(a.requireArg(2, "id"))));
    case "purge":
      return emitResult(p.purgeExpired(tenant));
    default:
      return unknown(a);
    }
  }

  // ── option → payload ───────────────────────────────────────────────────

  /// Build a payload from the options that are present (others stay untouched).
  protected static Json body(const CliArgs a, const string[2][] map) {
    auto b = Json.emptyObject;
    foreach (m; map)
      if (a.has(m[0]))
        b[m[1]] = a.opt(m[0]);
    return b;
  }

  /// --inactive / --active toggles.
  protected static Json withActive(const CliArgs a, Json b) {
    if (a.flag("inactive"))
      b["active"] = false;
    else if (a.flag("active"))
      b["active"] = true;
    return b;
  }

  // ── helpers ────────────────────────────────────────────────────────────

  /// A user by id, e-mail address or user name.
  protected IAUser userOf(string key) {
    auto user = ports.users.getUser(tenant, UserId(key));
    if (user.isNull)
      user = ports.users.findUser(tenant, key);
    if (user.isNull)
      throw new Exception("User '" ~ key ~ "' not found");
    return user;
  }

  protected static string command(const CliArgs a) {
    return a.requireArg(1, "command (list, get, create, …)");
  }

  protected static int unknown(const CliArgs a) {
    throw new CliUsageError("unknown command '" ~ a.arg(1) ~ "' for " ~ a.arg(0));
  }

  protected static E enumArg(E)(const CliArgs a, size_t index) {
    auto text = a.requireArg(index, enumValues!E().join("|"));
    E value;
    if (!tryParseEnum!E(text, value))
      throw new CliUsageError("'" ~ text ~ "' is not one of " ~ enumValues!E().join(", "));
    return value;
  }

  protected static T found(T)(T entity) {
    if (entity.isNull)
      throw new Exception(T.stringof ~ " not found");
    return entity;
  }

  protected int emit(Json data, lazy string text) {
    output(json ? data.toPrettyString ~ "\n" : text);
    return 0;
  }

  protected int emitTable(T)(const T[] items, Table table) {
    auto arr = Json.emptyArray;
    foreach (i; items)
      arr ~= i.toJson;
    return emit(arr, table.render ~ "%d record(s)\n".format(table.length));
  }

  protected int emitOne(T)(const T item) {
    return emit(item.toJson, item.toJson.toPrettyString ~ "\n");
  }

  protected int emitToken(TokenResponse r) {
    if (json || r.isSuccess)
      output(r.toJson.toPrettyString ~ "\n");
    else
      output("error: " ~ r.error ~ " — " ~ r.errorDescription ~ "\n");
    return r.isSuccess ? 0 : 1;
  }

  protected int emitResult(UsecaseResult r) {
    if (json)
      output(r.toJson.toPrettyString ~ "\n");
    else if (r.isSuccess) {
      output((r.message.length ? r.message : "OK") ~ (r.id.length ? " (" ~ r.id ~ ")" : "") ~ "\n");
      // one-time secrets (client secret, MFA seed) must be shown to the operator
      foreach (key; ["clientId", "clientSecret", "secret", "provisioningUri"])
        if (r.data.type == Json.Type.object && key in r.data)
          output("  %-16s %s\n".format(key ~ ":", r.data[key].get!string));
    } else
      output("error: " ~ r.message ~ "\n");
    return r.isSuccess ? 0 : 1;
  }
}

///
unittest {
  mixin(ShowTest!("IdentityCli"));

  auto cfg = testConfig();
  auto c = buildContainer(cfg);
  string out_;
  auto cli = new IdentityCli(c.ports, cfg, (string s) { out_ ~= s; });

  assert(cli.run(["users", "create", "--email=jane@example.com", "--password=Secret123", "--first-name=Jane"]) == 0);
  assert(cli.run(["users", "create", "--email=jane@example.com", "--password=Secret123"]) == 1); // duplicate
  out_ = "";
  assert(cli.run(["users", "list"]) == 0);
  assert(out_.canFind("jane@example.com") && out_.canFind("1 record(s)"));
  assert(cli.run(["users", "lock", "jane"]) == 0);
  assert(cli.run(["users", "status", "jane", "pendingVerification"]) == 1); // lifecycle violation
  assert(cli.run(["users", "status", "jane", "bogus"]) == 2);
  assert(cli.run(["users", "unlock", "jane@example.com"]) == 0);

  assert(cli.run(["groups", "create", "--name=admins"]) == 0);
  auto gid = c.ports.groups.listGroups(TenantId("default"))[0].id.value;
  assert(cli.run(["groups", "add-member", gid, "jane"]) == 0);

  out_ = "";
  assert(cli.run(["apps", "create", "--name=Portal", "--scopes=openid,profile"]) == 0);
  assert(out_.canFind("clientSecret:"));
  auto app = c.ports.applications.listApplications(TenantId("default"))[0];
  auto secret = out_.split("clientSecret:")[1].strip.split("\n")[0].strip;

  assert(cli.run(["policies", "create", "--name=Admins", "--rules=group:in:admins", "--apps=" ~ app.id.value]) == 0);
  assert(cli.run(["policies", "create", "--name=Broken", "--rules=planet:eq:mars"]) == 1);
  out_ = "";
  assert(cli.run(["policies", "evaluate", "--app=" ~ app.id.value, "--user=jane"]) == 0);
  assert(out_.canFind("Access granted"));

  // full flow through the CLI
  out_ = "";
  assert(cli.run(["login", "--email=jane@example.com", "--password=Secret123"]) == 0);
  auto session = out_.split("session ")[1].split(" ")[0];
  out_ = "";
  assert(cli.run(["token", "--session=" ~ session, "--client-id=" ~ app.clientId, "--client-secret=" ~ secret,
      "--scopes=openid"]) == 0);
  auto access = parseJsonString(out_)["access_token"].get!string;
  out_ = "";
  assert(cli.run(["introspect", access, "--json"]) == 0);
  assert(parseJsonString(out_)["active"].get!bool);
  assert(cli.run(["logout", session]) == 0);
  out_ = "";
  assert(cli.run(["introspect", access, "--json"]) == 0);
  assert(!parseJsonString(out_)["active"].get!bool);

  assert(cli.run(["risk-rules", "create", "--name=External", "--conditions=ip_range:not_in:10.0.0.0/8",
      "--level=high", "--mfa-type=totp"]) == 0);
  out_ = "";
  assert(cli.run(["risk-rules", "assess", "--user=jane", "--ip=8.8.8.8"]) == 0);
  assert(out_.canFind("Risk high"));

  assert(cli.run(["idps", "create", "--name=Azure", "--type=oidc", "--authorization-endpoint=https://login/authorize",
      "--client-id=abc", "--domains=example.com"]) == 0);
  out_ = "";
  assert(cli.run(["idps", "resolve", "joe@example.com", "--redirect-uri=https://app/cb"]) == 0);
  assert(out_.canFind("Azure") && out_.canFind("client_id=abc"));

  assert(cli.run(["frobnicate"]) == 2);
  assert(cli.run(["users", "frobnicate"]) == 2);
  assert(cli.run([]) == 2);
  assert(cli.run(["help"]) == 0);
  out_ = "";
  assert(cli.run(["stats", "--json"]) == 0);
  assert(parseJsonString(out_)["users"].get!long == 1);
}
