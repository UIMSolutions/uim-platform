/* global QUnit */
QUnit.config.autostart = false;
sap.ui.require([
  "uim/documentai/test/unit/formatter.qunit",
  "uim/documentai/test/unit/models.qunit",
  "uim/documentai/test/unit/session.qunit"
], function () {
  "use strict";
  QUnit.start();
});
