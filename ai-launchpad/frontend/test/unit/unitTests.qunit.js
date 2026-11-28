/* global QUnit */
QUnit.config.autostart = false;
sap.ui.require([
  "uim/ailaunchpad/test/unit/formatter.qunit",
  "uim/ailaunchpad/test/unit/models.qunit",
  "uim/ailaunchpad/test/unit/session.qunit"
], function () {
  "use strict";
  QUnit.start();
});
