/// <reference path="_all.ts" />

console.log("boot ang mat loaded");

module TestApp{
    angular.module("testApp", [])
        .controller("mainController", MainController);

}