(function () {
    "use strict";

    var eventsApp = angular.module("eventsApp");


    eventsApp.directive("datePicker", function () {
        
        return {
            restrict: "A",
            link: function (scope, element, attrs, controller) {
                element.datepicker();
            }
        };
    });


}());