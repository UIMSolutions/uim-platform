/* global QUnit */
QUnit.config.autostart = false;
sap.ui.require([
  "uim/datasphere/test/unit/formatter.qunit",
  "uim/datasphere/test/unit/models.qunit",
  "uim/datasphere/test/unit/session.qunit"
], function () {
  "use strict";
  QUnit.start();
});
