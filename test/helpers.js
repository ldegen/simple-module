var jsdom = require('jsdom');
var jquery = require('jquery');
var dom = new jsdom.JSDOM("<!DOCTYPE html><p>Hello world</p>");
global.$ = jquery(dom.window);
global.expect = require("chai").expect
