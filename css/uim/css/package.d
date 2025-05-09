﻿/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.css;

mixin(ImportPhobos!());

public { // Required uim libraries 
  import uim.infralevel;

  // import uim.filesystems;
  // import uim.models;
}

public { // Packages
  import uim.css.classes;
  import uim.css.collections;
  import uim.css.helpers;
  import uim.css.exceptions;
  import uim.css.factories;
  import uim.css.mixins;
  import uim.css.registries;
  import uim.css.tests;
}

public { // Modules 
  import uim.css.declaration;
  import uim.css.obj;
  import uim.css.rule;
  import uim.css.rules;
  import uim.css.media;
  import uim.css.interfaces;
  import uim.css.mixins;
  import uim.css.tests;
}

/* class DCSSx : DCSSRules {
	this() { super(); }
	this(DCSSObj[] someRules) { this(); }

	override protected void _init() { super._init; }

	string[] _properties;
	// CSS background properties
	struct Background {
		DCSS css;
		this(DCSS owner) {
			css = owner;
		}

		auto color(string color) {
			css.backgroundColor(color);
			return this;
		}

		auto image(string image) {
			css.backgroundImage(image);
			return this;
		}
		auto repeat(string void write() {
			css.backgroundRepeat(repeat);
			return this;
		}
		auto attachment(string attachment) {
			css.backgroundAttachment(attachment);
			return this;
		}
		auto position(string position) {
			css.backgroundPosition(position);
			return this;
		}
	}
	auto background() {
		return Background(this);
	}
	auto backgroundColor(string color) {
		_properties ~= "background-color: "~color;
		return this;
	}
	auto backgroundImage(string image) {
		_properties ~= "background-image: "~image;
		return this;
	}
	auto backgroundRepeat(string repeat) {
		_properties ~= "background-repeat: "~repeat;
		return this;
	}
	auto backgroundAttachment(string attachment) {
		_properties ~= "background-attachment: "~attachment;
		return this;
	}
	auto backgroundPosition(string position) {
		_properties ~= "background-position: "~position;
		return this;
	}

	// CSS Border properties
	struct Border {
		DCSS css;
		this(DCSS owner) {
			css = owner;
		}
		auto color(string color) {
			css.borderColor(color);
			return this;
		}
		auto style(string style) {
			css.borderStyle(style);
			return this;
		}
		auto topStyle(string style) {
			css.borderTopStyle(style);
			return this;
		}
		auto rightStyle(string style) {
			css.borderRightStyle(style);
			return this;
		}
		auto bottomStyle(string style) {
			css.borderBottomStyle(style);
			return this;
		}
		auto leftStyle(string style) {
			css.borderLeftStyle(style);
			return this;
		}
		auto width(string width) {
			css.borderWidth(width);
			return this;
		}
	}
	auto border() {
		return Border(this);
	}
	auto borderColor(string color) {
		_properties ~= "border-color: "~color;
		return this;
	}
	auto borderStyle(string style) {
		_properties ~= "border-style: "~style;
		return this;
	}
	auto borderTopStyle(string style) {
		_properties ~= "border-style: "~style;
		return this;
	}
	auto borderRightStyle(string style) {
		_properties ~= "border-style: "~style;
		return this;
	}
	auto borderBottomStyle(string style) {
		_properties ~= "border-style: "~style;
		return this;
	}
	auto borderLeftStyle(string style) {
		_properties ~= "border-style: "~style;
		return this;
	}
	auto borderWidth(string width) {
		_properties ~= "border-width: "~width;
		return this;
	}
	auto border(string properties) {
		_properties ~= "border: "~properties;
		return this;
	}

	// CSS Text properties
	struct Text {
		DCSS css;
		this(DCSS owner) { css = owner; }
		auto color(string color) {
			css.color(color);
			return this;			
		}
		auto align_(string val) {
			css.textAlign(val);
			return this;			
		}
		auto decoration(string decoration) { // values: overline, line-through, underline
			css.textDecoration(decoration);
			return this;			
		}
		auto textTransform(string transform) { // values: uppercase, lowercase, capitalize
			css.textTransform(transform);
			return this;			
		}
		auto indent(string indent) { 
			css.textIndent(indent);
			return this;			
		}
		auto letterSpacing(string spacing) { 
			css.letterSpacing(spacing);
			return this;			
		}
		auto lineHeight(string height) { 
			css.lineHeight(height);
			return this;			
		}		
		auto direction(string dir) { 
			css.direction(dir);
			return this;			
		}		
		auto wordSpacing(string spacing) { 
			css.wordSpacing(spacing);
			return this;			
		}		
		auto shadow(string shadow) { 
			css.textShadow(shadow);
			return this;			
		}		
	}	
	auto text() {
		return Text(this);
	}

	auto color(string color) {
		_properties ~= "color: "~color;
		return this;			
	}
	auto textAlign(string val) {
		_properties ~= "text-align: "~val;
		return this;			
	}
	auto textDecoration(string decoration) { // values: overline, line-through, underline
		_properties ~= "text-decoration: "~decoration;
		return this;			
	}
	auto textTransform(string transform) { // values: uppercase, lowercase, capitalize
		_properties ~= "text-transform: "~transform;
		return this;			
	}
	auto textIndent(string indent) { 
		_properties ~= "text-indent: "~indent;
		return this;			
	}
	auto letterSpacing(string spacing) { 
		_properties ~= "letter-spacing: "~spacing;
		return this;			
	}
	auto lineHeight(T)(T height) { 
		_properties ~= "line-height: %s".format(height);
		return this;			
	}		
	auto lineHeight(string height) { 
		_properties ~= "line-height: "~height;
		return this;			
	}		
	auto direction(string dir) { 
		_properties ~= "direction: "~dir;
		return this;			
	}		
	auto wordSpacing(string spacing) { 
		_properties ~= "word-spacing: "~spacing;
		return this;			
	}		
	auto textShadow(string shadow) { 
		_properties ~= "text-shadow: "~shadow;
		return this;			
	}		
	override string toString() {
		string result = _properties.join(";");
		_properties = null;
		return result;
	}
}
//auto CSS() { return new DCSS(); }
//auto CSS(CSSObj[] someRules) { return new DCSS(someRules); }

enum CS3Colors : string {
	Red = "red",
	Green = "green",
	Blue = "blue",
	Orange = "orange",
	Yellow = "yellow",
	Cyan = "cyan"
}

unittest {
	writeln("Testing ", __MODULE__);
//
//	auto css = CSSRuleSet;
//
//	auto media = CSSMedia("screen and (min-width: 480px)");
//	media.rules = media.rules ~ CSSRule("body", ["background-color": "lightgreen"]);
//	css.add(media);
//
//	media = CSSMedia("screen and (min-width: 480px)");
//	media.rules = media.rules ~ CSSRule(".h1", ["background-color": "lightgreen"]);
//	css.add(media);
//
//	css.add(CSSRule("#tt", ["background-color": "lightgreen"]));
//	writeln(css);

	//	auto css3 = CSS
	//		.media("screen and (min-width: 480px)", [
	//				CSSRule("img", ["background-color": "lightgreen"]),
	//				CSSRule("xxs", ["background-color": "lightgreen"])
	//			])
	//		.media("screen and (min-width: 490px)", [CSSRule("img", ["background-color": "lightgreen"])]);

	
	/*	string css_text = CSS
	 .background
	 .image("xxx")
	 .color("lightgreen");
	 	
} */

unittest {
}
