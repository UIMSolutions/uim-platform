/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.services.catalog;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Application service: the predefined SAP catalogue — extensions, dev space
/// types and project templates modelled on SAP Business Application Studio.
class StudioCatalogService : IStudioCatalogService {
  protected StudioRepositories repos;
  protected IStudioEventPublisher publisher;

  this(StudioRepositories repos, IStudioEventPublisher publisher) {
    this.repos = repos;
    this.publisher = publisher;
  }

  CatalogSeedReport seed(TenantId tenantId, UserId actor) {
    CatalogSeedReport report;
    report.tenantId = tenantId;

    void extension(string name, string displayName, string category, string[] dependencies,
        ExtensionScope scope_ = ExtensionScope.predefined) {
      if (!repos.extensions.findByName(tenantId, name).isNull) {
        report.skipped++;
        return;
      }
      auto e = Extension(tenantId);
      e.name = name;
      e.displayName = displayName;
      e.description = displayName ~ " for SAP Business Application Studio";
      e.scope_ = scope_;
      e.publisher = "SAP";
      e.category = category;
      e.dependencies = dependencies;
      e.createdBy = actor;
      e.updatedBy = actor;
      repos.extensions.save(e);
      created(report, "extension " ~ name);
    }

    void devSpaceType(string name, string description, string runtimeStack, string[] extensions, ProjectType[] types) {
      if (!repos.devSpaceTypes.findByName(tenantId, name).isNull) {
        report.skipped++;
        return;
      }
      auto t = DevSpaceType(tenantId);
      t.name = name;
      t.description = description;
      t.category = DevSpaceTypeCategory.predefined;
      t.predefinedExtensions = extensions;
      t.supportedProjectTypes = types;
      t.runtimeStack = runtimeStack;
      t.createdBy = actor;
      t.updatedBy = actor;
      repos.devSpaceTypes.save(t);
      created(report, "dev space type " ~ name);
    }

    void projectTemplate(string name, string title, TemplateCategory category, ProjectType target,
        string[] requiredExtensions, string[] files, KeyValue[] parameters = null) {
      if (!repos.projectTemplates.findByName(tenantId, name).isNull) {
        report.skipped++;
        return;
      }
      auto t = ProjectTemplate(tenantId);
      t.name = name;
      t.title = title;
      t.description = "Generates a " ~ title ~ " project";
      t.category = category;
      t.targetProjectType = target;
      t.requiredExtensions = requiredExtensions;
      t.scaffoldFiles = files;
      t.parameters = parameters;
      t.createdBy = actor;
      t.updatedBy = actor;
      repos.projectTemplates.save(t);
      created(report, "template " ~ name);
    }

    // ── extensions (dependencies first) ────────────────────────────────────
    extension("sap.basic-tools", "Basic Tools", "Core", null);
    extension("sap.ui5-language", "SAPUI5 Language Assistant", "UI", null);
    extension("sap.service-center", "Service Center", "Connectivity", null);
    extension("sap.fiori-tools", "SAP Fiori Tools", "UI", ["sap.ui5-language", "sap.service-center"]);
    extension("sap.cds-language", "CDS Language Support", "CAP", null);
    extension("sap.cap-tools", "CAP Tools", "CAP", ["sap.cds-language"]);
    extension("sap.java-tools", "Java Tools", "Languages", null);
    extension("sap.mta-tools", "MTA Tools", "Deployment", null);
    extension("sap.cf-tools", "Cloud Foundry Tools", "Deployment", null);
    extension("sap.hana-tools", "SAP HANA Tools", "Database", ["sap.cds-language"]);
    extension("sap.mdk-tools", "Mobile Development Kit", "Mobile", null);
    extension("sap.workflow-tools", "Workflow Tools", "Process", null);
    extension("sap.kyma-tools", "Kyma Tools", "Deployment", null, ExtensionScope.additional);
    extension("sap.abap-deployment", "ABAP Deployment", "Deployment", ["sap.fiori-tools"], ExtensionScope.additional);
    extension("sap.ai-assistant", "AI Code Assistant", "Productivity", null, ExtensionScope.additional);

    // ── dev space types ────────────────────────────────────────────────────
    with (ProjectType) {
      devSpaceType("SAP Fiori", "Develop SAP Fiori and SAPUI5 applications", "Node.js 20",
        ["sap.basic-tools", "sap.fiori-tools", "sap.ui5-language", "sap.service-center", "sap.mta-tools", "sap.cf-tools"],
        [sapFiori, sapFioriElements, sapUi5, multitarget, basic]);
      devSpaceType("Full-Stack Cloud Application", "Develop CAP services with SAP Fiori UIs", "Node.js 20, Java 21",
        ["sap.basic-tools", "sap.cap-tools", "sap.cds-language", "sap.fiori-tools", "sap.ui5-language",
          "sap.service-center", "sap.java-tools", "sap.mta-tools", "sap.cf-tools"],
        [capNodeJs, capJava, sapFiori, sapFioriElements, sapUi5, multitarget, sideBySideExtension, basic]);
      devSpaceType("SAP HANA Native Application", "Develop SAP HANA database artifacts", "Node.js 20, HANA client",
        ["sap.basic-tools", "sap.hana-tools", "sap.cds-language", "sap.mta-tools", "sap.cf-tools"],
        [hanaNative, multitarget, basic]);
      devSpaceType("SAP Mobile Application", "Develop MDK mobile applications", "Node.js 20",
        ["sap.basic-tools", "sap.mdk-tools", "sap.mta-tools", "sap.cf-tools"], [mdk, multitarget, basic]);
      devSpaceType("SAP Workflow", "Develop workflow modules", "Node.js 20",
        ["sap.basic-tools", "sap.workflow-tools", "sap.mta-tools", "sap.cf-tools"], [workflow, multitarget, basic]);
      devSpaceType("Basic", "Minimal dev space with git and a terminal", "Node.js 20", ["sap.basic-tools"], null);
    }

    // ── project templates ──────────────────────────────────────────────────
    projectTemplate("fiori-list-report", "SAP Fiori Elements List Report", TemplateCategory.sapFiori,
      ProjectType.sapFioriElements, ["sap.fiori-tools"],
      ["webapp/manifest.json", "webapp/Component.js", "webapp/i18n/i18n.properties", "ui5.yaml", "package.json"],
      [KeyValue("floorplan", "ListReportObjectPage"), KeyValue("odataVersion", "4")]);
    projectTemplate("fiori-freestyle", "SAPUI5 Freestyle Application", TemplateCategory.sapFiori, ProjectType.sapUi5,
      ["sap.ui5-language"], ["webapp/manifest.json", "webapp/Component.js", "webapp/view/Main.view.xml",
        "webapp/controller/Main.controller.js", "ui5.yaml", "package.json"]);
    projectTemplate("cap-project", "CAP Project (Node.js)", TemplateCategory.sapCap, ProjectType.capNodeJs,
      ["sap.cap-tools"], ["package.json", "db/schema.cds", "srv/service.cds", ".cdsrc.json"], [KeyValue("runtime", "nodejs")]);
    projectTemplate("cap-java-project", "CAP Project (Java)", TemplateCategory.sapCap, ProjectType.capJava,
      ["sap.cap-tools", "sap.java-tools"], ["pom.xml", "db/schema.cds", "srv/service.cds",
        "srv/src/main/java/Application.java"], [KeyValue("runtime", "java")]);
    projectTemplate("hana-database", "SAP HANA Database Project", TemplateCategory.sapHana, ProjectType.hanaNative,
      ["sap.hana-tools"], ["db/src/.hdiconfig", "db/package.json", "mta.yaml"]);
    projectTemplate("mdk-app", "MDK Application", TemplateCategory.sapMdk, ProjectType.mdk, ["sap.mdk-tools"],
      ["Application.app", "Pages/Main.page", "mta.yaml"]);
    projectTemplate("workflow-module", "Workflow Module", TemplateCategory.sapWorkflow, ProjectType.workflow,
      ["sap.workflow-tools"], ["workflows/approval.workflow", "mta.yaml"]);
    projectTemplate("basic-mta", "Basic Multitarget Application", TemplateCategory.general, ProjectType.multitarget,
      ["sap.mta-tools"], ["mta.yaml", "README.md"]);

    publisher.publish("studio.catalog.seeded", Json.emptyObject.set("tenantId", tenantId.value)
        .set("created", report.created).set("skipped", report.skipped));
    return report;
  }

  protected static void created(ref CatalogSeedReport report, string item) {
    report.created++;
    report.items ~= item;
  }
}
