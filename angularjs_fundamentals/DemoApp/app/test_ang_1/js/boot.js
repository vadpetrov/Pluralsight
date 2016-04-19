/// <reference path="_all.js" />

"use strict";

console.log("boot ang2 file");

var TestApp;

(function (TestApp) {
    angular.module("testApp", [])
    .controller("mainController", TestApp.MainController);
    

})(TestApp || (TestApp = {}));