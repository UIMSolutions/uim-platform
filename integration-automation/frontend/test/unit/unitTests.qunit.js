/* global QUnit */
QUnit.config.autostart = false;
sap.ui.require([
  "uim/integrationautomation/test/unit/formatter.qunit",
  "uim/integrationautomation/test/unit/models.qunit",
  "uim/integrationautomation/test/unit/session.qunit"
], function () {
  "use strict";
  QUnit.start();
});
