/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The resource catalogue of the translation service: which kinds exist, how
/// they are named per protocol, their table columns and actions — plus the
/// non-resource operations (translate texts / documents, process jobs).
module uim.platform.translation.presentation.resources.registry;

import uim.platform.translation;
import uim.platform.translation.presentation.resources.adapter;

mixin(ShowModule!());

@safe:

/// Payload fields that reference a project (accept an id or a unique project name).
enum string[] projectReferenceFields = ["projectId"];

/// Run `action`; business exceptions become ResourceErrors with their status.
T translating(T)(scope T delegate() @safe action) {
  try
    return action();
  catch (TranslationException e) {
    auto code = e.status == 404 ? "NotFound" : e.status == 409 ? "Conflict"
      : e.status == 422 ? "BusinessRuleViolation" : "BadRequest";
    throw new ResourceError(e.status, code, e.msg);
  }
}

class ResourceRegistry {
  protected IResourceAdapter[] _adapters;
  TranslationPorts ports;

  this(TranslationPorts ports) {
    this.ports = ports;
    auto p = ports;

    _adapters ~= new ResourceAdapter!(TranslationProject, TranslationProjectId, CreateProjectRequest, UpdateProjectRequest)(
      p.projects, "projects", "TranslationProjects", "TranslationProject", "Projects", "")
      .column("Name", "name").column("Type", "projectType").column("Source", "sourceLanguage")
      .column("Targets", "targetLanguages").column("Provider", "provider").column("Domain", "domainName")
      .column("Status", "status").column("Texts", "textCount").column("Done %", "completionPercent").column("ID", "id")
      .action("activate", "Activate", (who, id, _) => p.projects.activate(who.tenantId, id, who.userId))
      .action("translate", "Translate All", (who, id, params) => p.projects.translate(who.tenantId, id,
          fieldBool(params, "force"), who.userId), ["force"])
      .action("archive", "Archive", (who, id, _) => p.projects.archive(who.tenantId, id, who.userId))
      .action("reopen", "Reopen", (who, id, _) => p.projects.reopen(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(ProjectText, ProjectTextId, CreateProjectTextRequest, UpdateProjectTextRequest)(
      p.texts, "texts", "ProjectTexts", "ProjectText", "Texts", "projectId")
      .column("Key", "name").column("Project", "projectName").column("Source Text", "sourceText")
      .column("Type", "textType").column("Status", "status").column("Translations", "translations").column("ID", "id")
      .action("translate", "Translate", (who, id, _) => p.texts.translate(who.tenantId, id, who.userId))
      .action("set-translation", "Set Translation", (who, id, params) => p.texts.setTranslation(who.tenantId, id,
          fieldString(params, "language"), fieldString(params, "text"), who.userId), ["language", "text"])
      .action("review", "Review", (who, id, params) => p.texts.review(who.tenantId, id,
          fieldString(params, "language"), who.userId), ["language"]);

    _adapters ~= new ResourceAdapter!(GlossaryEntry, GlossaryEntryId, CreateGlossaryEntryRequest, UpdateGlossaryEntryRequest)(
      p.glossary, "glossaries", "GlossaryEntries", "GlossaryEntry", "Glossary", "")
      .column("Source Term", "sourceTerm").column("Target Term", "targetTerm").column("From", "sourceLanguage")
      .column("To", "targetLanguage").column("Domain", "domainName").column("Mandatory", "mandatory").column("ID", "id");

    _adapters ~= new ResourceAdapter!(TranslationJob, TranslationJobId, SubmitJobRequest, UpdateJobRequest)(
      p.jobs, "jobs", "TranslationJobs", "TranslationJob", "Jobs", "")
      .column("Name", "name").column("Type", "jobType").column("Status", "status").column("Provider", "provider")
      .column("Quality", "qualityScore").column("Characters", "characterCount").column("Submitted", "createdAt")
      .column("Message", "statusMessage").column("ID", "id")
      .appendOnly()
      .action("process", "Process Now", (who, id, _) => p.jobs.process(who.tenantId, id, who.userId))
      .action("cancel", "Cancel", (who, id, _) => p.jobs.cancel(who.tenantId, id, who.userId))
      .action("retry", "Retry", (who, id, _) => p.jobs.retry(who.tenantId, id, who.userId));

    _adapters ~= new CatalogAdapter!Language(() => p.catalog.languages, "languages", "Languages", "Language", "Languages")
      .column("Code", "id").column("Name", "name").column("Native Name", "nativeName").column("RTL", "rightToLeft");
    _adapters ~= new CatalogAdapter!TranslationDomain(() => p.catalog.domains, "domains", "TranslationDomains",
      "TranslationDomain", "Domains").column("Code", "id").column("Name", "name");
    _adapters ~= new CatalogAdapter!TextTypeInfo(() => p.catalog.textTypes, "text-types", "TextTypes", "TextType",
      "Text Types").column("ID", "id").column("Name", "name").column("Max Length", "recommendedMaxLength")
      .column("Description", "description");
    _adapters ~= new CatalogAdapter!ProviderInfo(() => p.catalog.providers, "providers", "Providers", "Provider",
      "Providers").column("ID", "id").column("Name", "name").column("Available", "available")
      .column("Description", "description");
  }

  IResourceAdapter[] adapters() {
    return _adapters;
  }

  /// Adapter by REST path / CLI command (null if unknown).
  IResourceAdapter byPath(string path) {
    foreach (a; _adapters)
      if (a.path == path)
        return a;
    return null;
  }

  /// Adapter by OData entity set (null if unknown).
  IResourceAdapter bySet(string setName) {
    foreach (a; _adapters)
      if (a.setName == setName)
        return a;
    return null;
  }

  /// Adapter owning an OData action name (null if unknown); `action` receives the action.
  IResourceAdapter byODataAction(string odataName, out ResourceAction action) {
    foreach (a; _adapters)
      foreach (act; a.actions)
        if (act.odataName == odataName) {
          action = act;
          return a;
        }
    return null;
  }

  /// An id, or the id of the unique resource of `adapter` with that name.
  string resolve(IResourceAdapter adapter, TenantId tenantId, string idOrName) {
    if (adapter.get(tenantId, idOrName).type != Json.Type.null_)
      return idOrName;
    auto matches = adapter.list(tenantId, ["name": idOrName]);
    if (matches.length == 1)
      return matches[0]["id"].get!string;
    if (matches.length > 1)
      throw new ResourceError(400, "Ambiguous", "'" ~ idOrName ~ "' matches " ~ matches.length.to!string
          ~ " " ~ adapter.path ~ " — use the id");
    throw new ResourceError(404, "NotFound", adapter.typeName ~ " '" ~ idOrName ~ "' not found");
  }

  /// A copy of `body` with every project reference given by name replaced by its id.
  Json withReferences(TenantId tenantId, Json body) {
    if (body.type != Json.Type.object)
      return body;
    auto result = Json.emptyObject;
    foreach (k, v; body.get!(Json[string]))
      result[k] = projectReferenceFields.canFind(k) && jsonText(v).length > 0
        ? Json(resolve(byPath("projects"), tenantId, jsonText(v))) : v;
    return result;
  }

  /// Statistics payload.
  Json statistics(TenantId tenantId) {
    return encode(ports.statistics.statistics(tenantId), true);
  }

  /// Translate texts. Body: sourceLanguage, targetLanguage, texts (array, or
  /// comma separated) or text, provider, domainName (or domain), textType.
  Json translateTexts(RequestIdentity who, Json body) {
    TranslateTextsRequest r;
    r.tenantId = who.tenantId;
    r.actor = who.userId;
    r.sourceLanguage = fieldString(body, "sourceLanguage");
    r.targetLanguage = fieldString(body, "targetLanguage");
    auto texts = member(body, "texts");
    if (texts.type == Json.Type.array)
      foreach (t; texts.get!(Json[]))
        r.texts ~= jsonText(t);
    else if (texts.type == Json.Type.string)
      r.texts = [texts.get!string];
    else if (fieldString(body, "text").length > 0)
      r.texts = [fieldString(body, "text")];
    r.provider = fieldString(body, "provider");
    r.domainName = fieldString(body, "domainName", fieldString(body, "domain"));
    r.textType = fieldString(body, "textType");
    return translating(() => encode(ports.translate.translateTexts(r), true));
  }

  /// Translate a document. Body: sourceLanguage, targetLanguage, content,
  /// contentType, provider, domainName (or domain).
  Json translateDocument(RequestIdentity who, Json body) {
    TranslateDocumentRequest r;
    r.tenantId = who.tenantId;
    r.actor = who.userId;
    r.sourceLanguage = fieldString(body, "sourceLanguage");
    r.targetLanguage = fieldString(body, "targetLanguage");
    r.content = fieldString(body, "content");
    r.contentType = fieldString(body, "contentType", "text/plain");
    r.provider = fieldString(body, "provider");
    r.domainName = fieldString(body, "domainName", fieldString(body, "domain"));
    return translating(() => encode(ports.translate.translateDocument(r), true));
  }

  /// Process the pending jobs of the tenant now.
  Json processJobs(TenantId tenantId, int limit = 0) {
    return encode(ports.jobs.processPending(tenantId, limit), true);
  }
}

///
unittest {
  mixin(ShowTest!("ResourceRegistry"));

  TranslationConfig cfg;
  cfg.storage = "memory";
  auto registry = new ResourceRegistry(buildContainer(cfg).ports);
  RequestIdentity who;
  who.tenantId = TenantId("t1");
  who.userId = UserId("cli");

  auto projects = registry.byPath("projects");
  auto project = projects.create(who, parseJsonString(
      `{"name": "Shop", "sourceLanguage": "en", "targetLanguages": "de, fr", "provider": "mltr"}`));
  assert(project["status"].get!string == "draft" && project["targetLanguages"].length == 2);

  // texts reference the project by name
  auto texts = registry.byPath("texts");
  auto text = texts.create(who, registry.withReferences(who.tenantId, parseJsonString(
      `{"projectId": "Shop", "name": "BUTTON_SAVE", "sourceText": "Save", "maxLength": "20"}`)));
  assert(text["projectId"].get!string == project["id"].get!string && text["projectName"].get!string == "Shop");

  auto translated = projects.invoke(who, project["id"].get!string, "translate", Json.emptyObject);
  assert(translated["status"].get!string == "completed" && translated["completionPercent"].get!long == 100);
  auto withText = texts.invoke(who, text["id"].get!string, "set-translation", parseJsonString(`{"language": "de", "text": "Sichern"}`));
  assert(withText["translations"][0]["reviewed"].get!bool);

  // PATCH semantics
  auto patched = projects.update(who, project["id"].get!string, parseJsonString(`{"description": "web shop"}`));
  assert(patched["description"].get!string == "web shop" && patched["targetLanguages"].length == 2);

  // business errors become ResourceErrors with HTTP status
  int status;
  try projects.create(who, parseJsonString(`{"name": "Shop", "targetLanguages": ["de"]}`));
  catch (ResourceError e) status = e.status;
  assert(status == 409);

  auto r = registry.translateTexts(who, parseJsonString(`{"sourceLanguage": "en", "targetLanguage": "es", "texts": ["Save", "Cancel"]}`));
  assert(r["count"].get!long == 2 && r["translations"][1]["translatedText"].get!string == "Cancelar");
  assert(registry.translateTexts(who, parseJsonString(`{"sourceLanguage": "en", "targetLanguage": "de", "text": "Search"}`))
      ["translations"][0]["translatedText"].get!string == "Suchen");
  status = 0;
  try registry.translateTexts(who, parseJsonString(`{"sourceLanguage": "en", "targetLanguage": "zz", "text": "x"}`));
  catch (ResourceError e) status = e.status;
  assert(status == 422);
  auto d = registry.translateDocument(who, parseJsonString(`{"sourceLanguage": "en", "targetLanguage": "it", "content": "Save\nCancel"}`));
  assert(d["translatedContent"].get!string == "Salva\nAnnulla");

  // jobs are immutable, processed by action or processJobs
  auto jobs = registry.byPath("jobs");
  auto job = jobs.create(who, parseJsonString(`{"jobType": "text", "sourceLanguage": "en", "targetLanguage": "fr", "content": "Welcome"}`));
  assert(job["status"].get!string == "pending");
  status = 0;
  try jobs.update(who, job["id"].get!string, parseJsonString(`{"content": "x"}`));
  catch (ResourceError e) status = e.status;
  assert(status == 405);
  assert(registry.processJobs(who.tenantId)["completed"].get!long == 1);
  assert(jobs.get(who.tenantId, job["id"].get!string)["translatedContent"].get!string == "Bienvenue");

  // reference data
  assert(registry.byPath("languages").get(who.tenantId, "de")["name"].get!string == "German");
  assert(registry.bySet("TranslationDomains").list(who.tenantId).length == 20);
  assert(registry.byPath("providers").list(who.tenantId, ["available": "true"]).length == 4);

  ResourceAction action;
  assert(registry.byODataAction("TranslateTranslationProject", action) is projects && action.parameters == ["force"]);
  assert(registry.byODataAction("SetTranslationProjectText", action) is texts);
  assert(registry.statistics(who.tenantId)["projectsCompleted"].get!long == 1);
  assert(registry.bySet("ProjectTexts").inputFields[0].name == "projectId");
}
