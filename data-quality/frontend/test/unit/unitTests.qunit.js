/* global QUnit */
QUnit.config.autostart = false;
sap.ui.require([
  "uim/dataquality/test/unit/formatter.qunit",
  "uim/dataquality/test/unit/models.qunit",
  "uim/dataquality/test/unit/session.qunit"
], function () {
  "use strict";
  QUnit.start();
});
