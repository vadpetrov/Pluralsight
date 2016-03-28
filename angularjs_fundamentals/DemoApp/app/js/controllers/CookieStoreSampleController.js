(function () {


    "use strict";

    var module = angular.module("eventsApp");
    module.controller("CookieStoreSampleController", CookieStoreSampleController);


    //http://stackoverflow.com/questions/12624181/angularjs-how-to-set-expiration-date-for-cookie-in-angularjs
    function CookieStoreSampleController($scope, $cookieStore) {

        $scope.event = { id: 1, name: "My Event" };

        $scope.saveEventToCookie = function (event) {

            var d = new Date();
            d.setDate(d.getDate() + 7);
            $cookieStore.put("event", event, { expires: d});
        };

        $scope.getEventFromCookie = function () {
            console.log($cookieStore.get("event"));
        };

        $scope.removeEventCookie = function () {
            $cookieStore.remove('event');
        };
    };

}());