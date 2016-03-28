(function () {
    "use strict";

    var eventsApp = angular.module("eventsApp");


    eventsApp.directive("eventThumbnail", function () {

        //directive with model bindning
        return {
            restrict: "E",
            replace: true, //will replace event-thumbnail tag with template html instead of append
            templateUrl: "/templates/directives/eventThumbnail.html",
            scope: {
                //event:"=thItem"
                event: "="
            }
        };

        //directive without model bindning
        //return {
        //    restrict: "E",
        //    replace: true, //will replace event-thumbnail tag with template html instead of append
        //    templateUrl: "/templates/directives/eventThumbnail.html"
        //};

    });

}());