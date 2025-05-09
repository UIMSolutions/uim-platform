﻿/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.css.rules;

mixin(Version!("test_uim_css"));

mixin(Version!("test_uim_css"));

import uim.css;
@safe:
<<<<<<< HEAD

class DCSSRules : DCSSObj {
	this() { super(); }
	this(DCSSRule[] someRules) { this().rules(someRules); }
	this(DCSSRules aRules) { this().rules(aRules); }
=======
>>>>>>> 8504c0aa77a642ca4cdfc94f5177dce259b60200

class DCSSRules : DCSSObj {
	this() {
		super();
	}

	this(DCSSRule[] someRules) {
		this().rules(someRules);
	}

	this(DCSSRules aRules) {
		this().rules(aRules);
	}

	override protected void _init() {
		super._init;
	}

	DCSSRule[] _rules;
	DCSSRule[] rules() {
		return _rules;
	}

	O rules(this O)(DCSSRule[] someRules) {
		_rules ~= someRules;
		return cast(O) this;
	}

	O rules(this O)(DCSSRules someRules) {
		_rules ~= someRules.rules;
		return cast(O) this;
	}

	O rules(this O)(string[string][string] someDeclarations) {
		foreach (aSelector, aDeclaration; someDeclarations) {
			this.rule(aSelector, aDeclaration);
		}
		return cast(O) this;
	}

	unittest {
		assert(CSSRules.rules(
				["body": ["background-color": "lightgreen"]]) == "body{background-color:lightgreen}");
	}
}

auto find(string selector) {
	foreach (i, rule; _rules)
		if (rule.selector == selector)
			return i;
	return -1;
}

O removeKey(this O)(long index) {
	if (index < _rules.length)
		_rules = _rules.removeKey(index);
}

o sub(this O)(string selector) {
	auto index = find(selector);
	removeKey(index);
}

/// Adding CSS rules
O add(this O)(DCSSRules aRules) {
	_rules ~= aRules.rules;
	return cast(O) this;
}

O add(this O)(DCSSRule aRule) {
	_rules ~= aRule;
	return cast(O) this;
}

O add(this O)(DCSSMedia aRule) {
	_rules ~= aRule;
	return cast(O) this;
}

O rule(this O)(DCSSRule aRule) {
	_rules ~= aRule;
	return cast(O) this;
}

O rule(this O)(string aSelector, string name, string value) {
	_rules ~= CSSRule(aSelector, name, value);
	return cast(O) this;
}

O rule(this O)(string aSelector, string[string] someDeclarations) {
	_rules ~= CSSRule(aSelector, someDeclarations);
	return cast(O) this;
}

O opCall(this O)(string aSelector, string name, string value) {
	_rules ~= CSSRule(aSelector, name, value);
	return cast(O) this;
}

O opCall(this O)(string aSelector, string[string] someDeclarations) {
	_rules ~= CSSRule(aSelector, someDeclarations);
	return cast(O) this;
}

O opCall(this O)(DCSSRule aRule) {
	return _add(aRule);
}

O opCall(this O)(DCSSRule aRules) {
	return _add(aRules);
}

bool opEquals(string css) {
	return toString == css;
}

override string toString() {
	return _rules.map!(a => a.toString).join("");
}
}
auto CSSRules() {
	return new DCSSRules();
}

auto CSSRules(DCSSRule[] someRules) {
	return new DCSSRules(someRules);
}

auto CSSRules(DCSSRules someRules) {
	return new DCSSRules(someRules);
}

unittest {
	assert(CSSRules.rule(CSSRule("body", ["background-color": "lightgreen"])) == "body{background-color:lightgreen}");
	assert(CSSRules.rule("body", "background-color", "lightgreen") == "body{background-color:lightgreen}");
	assert(CSSRules.rule("body", ["background-color": "lightgreen"]) == "body{background-color:lightgreen}");
	assert(CSSRules
			.rule("body", ["background-color": "lightgreen"])
			.rule("test", ["background-color": "lightgreen"]) == "body{background-color:lightgreen}test{background-color:lightgreen}");
}
}
