(function () {

    "use strict";

    var module = angular.module("eventsApp");
    module.controller("EventListController", EventListController);

    function EventListController($scope, $location, eventData) {
        $scope.events = eventData.getAllEvents();
    };

}());