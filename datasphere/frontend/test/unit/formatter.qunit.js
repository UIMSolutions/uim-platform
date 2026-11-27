/* global QUnit */
sap.ui.define(["uim/datasphere/model/formatter"], function (formatter) {
  "use strict";

  QUnit.module("formatter");

  QUnit.test("states and icons", function (assert) {
    assert.strictEqual(formatter.state("completed"), "Success");
    assert.strictEqual(formatter.state("failed"), "Error");
    assert.strictEqual(formatter.state("changesToDeploy"), "Warning");
    assert.strictEqual(formatter.state("nonsense"), "None");
    assert.strictEqual(formatter.icon("valid"), "sap-icon://connected");
    assert.strictEqual(formatter.typeIcon("taskChain"), "sap-icon://chain-link");
  });

  QUnit.test("usage and sizes", function (assert) {
    assert.strictEqual(formatter.usageState(95), "Error");
    assert.strictEqual(formatter.usageState(80), "Warning");
    assert.strictEqual(formatter.usageState(10), "Success");
    assert.strictEqual(formatter.percent(140), 100);
    assert.strictEqual(formatter.gib(0.25), "256 MiB");
    assert.strictEqual(formatter.gib(12.5), "12.5 GiB");
    assert.strictEqual(formatter.mib(2048), "2 GiB");
    assert.strictEqual(formatter.mibUsage.call(formatter, 93, 25600), "93 MiB / 25 GiB");
  });

  QUnit.test("durations and counts", function (assert) {
    assert.strictEqual(formatter.duration(950), "950 ms");
    assert.strictEqual(formatter.duration(4200), "4.2 s");
    assert.strictEqual(formatter.duration(64200), "1 min 4 s");
    assert.strictEqual(formatter.count(1234567), "1,234,567");
    assert.strictEqual(formatter.joined(["a", "b"]), "a, b");
  });
});
