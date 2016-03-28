(function () {
    
    "use strict";

    var module = angular.module("eventsApp");
    module.controller("MainMenuController", MainMenuController);
    

    function MainMenuController($scope, $location) {

        console.log('absUrl:', $location.absUrl());
        console.log('protocol:', $location.protocol());
        console.log('port:', $location.port());
        console.log('host:', $location.host());
        console.log('path:', $location.path());
        console.log('search:', $location.search());//brings query string params object
        console.log('hash:', $location.hash());//brings hash - string after # sign
        console.log('url:', $location.url());

        $scope.createEvent = function () {
            $location.replace();
            $location.url("/newEvent");
        }
    };

}());