/* global QUnit */
QUnit.config.autostart = false;
sap.ui.require([
  "uim/dataretention/test/unit/formatter.qunit",
  "uim/dataretention/test/unit/models.qunit",
  "uim/dataretention/test/unit/session.qunit"
], function () {
  "use strict";
  QUnit.start();
});
