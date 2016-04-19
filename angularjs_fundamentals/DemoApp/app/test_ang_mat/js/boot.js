/// <reference path="_all.ts" />
console.log("boot ang mat loaded");
var TestApp;
(function (TestApp) {
    angular.module("testApp", [])
        .controller("mainController", TestApp.MainController);
})(TestApp || (TestApp = {}));
//# sourceMappingURL=boot.js.map