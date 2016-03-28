(function () {

    "use strict";

    var module = angular.module("eventsApp");
    module.controller("FilterSampleController", FilterSampleController);


    function FilterSampleController1($scope, $filter) {

        $scope.data = {};

        var durations = $filter("durations");

        $scope.data.duration1 = durations(1);
        $scope.data.duration2 = durations(2);
        $scope.data.duration3 = durations(3);
        $scope.data.duration4 = durations(4);
    };

    function FilterSampleController($scope, durationsFilter) {

        $scope.data = {};
        $scope.data.duration1 = durationsFilter(1);
        $scope.data.duration2 = durationsFilter(2);
        $scope.data.duration3 = durationsFilter(3);
        $scope.data.duration4 = durationsFilter(4);
    };

}());