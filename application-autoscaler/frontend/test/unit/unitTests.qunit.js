/* global QUnit */
QUnit.config.autostart = false;
sap.ui.require([
  "uim/autoscaler/test/unit/formatter.qunit",
  "uim/autoscaler/test/unit/models.qunit",
  "uim/autoscaler/test/unit/session.qunit"
], function () {
  "use strict";
  QUnit.start();
});
