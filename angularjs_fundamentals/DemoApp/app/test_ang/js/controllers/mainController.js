/// <reference path="_all.js" />

(function () {
    "use strict";

    var module = angular.module("testApp");
    module.controller("mainController", MainController);


    function MainController() {

        var vm = this;
        vm.id = "Angular main controller";
    };

}());