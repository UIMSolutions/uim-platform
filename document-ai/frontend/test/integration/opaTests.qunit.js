/* global QUnit */
QUnit.config.autostart = false;

/**
 * Journey against a running backend with demo data (authMode "open"):
 *   ./build/uim-document-ai-cli seed --data-file=data/document-ai.json
 *   DOCAI_AUTH_MODE=open ./build/uim-document-ai-platform-service
 *   → http://localhost:8096/app/test/integration/opaTests.qunit.html
 */
sap.ui.require([
  "sap/ui/test/opaQunit",
  "sap/ui/test/Opa5",
  "sap/ui/test/actions/Press"
], function (opaTest, Opa5, Press) {
  "use strict";

  var VIEW = "Main";
  Opa5.extendConfig({ viewNamespace: "uim.documentai.view.", autoWait: true, timeout: 30 });

  QUnit.module("Document AI");

  opaTest("lists documents and the KPI header", function (Given, When, Then) {
    Given.iStartMyUIComponent({ componentConfig: { name: "uim.documentai", async: true } });
    Then.waitFor({
      viewName: VIEW, id: "documentsTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function (table) { Opa5.assert.ok(table.getItems().length >= 1, "documents are listed"); }
    });
    Then.waitFor({
      viewName: VIEW, id: "kpis",
      success: function (box) { Opa5.assert.ok(box.getBindingContext(), "Statistics bound"); }
    });
  });

  opaTest("shows the schemas", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("schemas"); bar.fireSelect({ key: "schemas" }); }
    });
    Then.waitFor({
      viewName: VIEW, id: "schemasTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "schemas are listed"); }
    });
  });

  opaTest("opens a document with its extracted values", function (Given, When, Then) {
    When.waitFor({
      viewName: VIEW, id: "tabs",
      success: function (bar) { bar.setSelectedKey("documents"); bar.fireSelect({ key: "documents" }); }
    });
    When.waitFor({
      viewName: VIEW, controlType: "sap.m.ColumnListItem",
      matchers: function (item) { return item.getParent() && item.getParent().getId().endsWith("documentsTable"); },
      actions: new Press()
    });
    Then.waitFor({
      viewName: "DocumentDetail", id: "headerTable",
      check: function (table) { return table.getItems().length > 0; },
      success: function () { Opa5.assert.ok(true, "the header values of the document are shown"); }
    });
    Then.iTeardownMyUIComponent();
  });

  QUnit.start();
});
