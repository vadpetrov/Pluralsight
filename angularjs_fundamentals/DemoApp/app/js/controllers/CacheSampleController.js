(function () {


    "use strict";

    var module = angular.module("eventsApp");
    module.controller("CacheSampleController", CacheSampleController);


    function CacheSampleController($scope, myCache) {

        $scope.addToCache = function (key, value) {
            myCache.put(key, value);
        };

        $scope.readFromCache = function (key) {
            return myCache.get(key);
        };

        $scope.getCacheStats = function () {
            return myCache.info();
        };
    };

}());