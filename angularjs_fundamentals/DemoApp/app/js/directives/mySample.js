(function () {
    "use strict";

    var eventsApp = angular.module("eventsApp");

    console.log("here");

    eventsApp.directive("mySample", function ($compile) {

        //return {
        //    restrict: "E", //default is A
        //    link: function (scope, element, attrs, controller) {
        //        var markup = "<input class='input-sm' type='text' ng-model='sampleData' /> {{sampleData}}<br/>";                
        //        angular.element(element).html($compile(markup)(scope));
        //    }
        //};

        //return {
        //    restrict: "E", //default is A
        //    template: "<input class='input-sm' type='text' ng-model='sampleData' />{{sampleData}}<br/>"
        //};

        return {
            restrict: "C", //default is A
            template: "<input class='input-sm' style='margin-top:10px;' type='text' ng-model='sampleData' />{{sampleData}}<br/>",
            //makes multiple directives isolated from each other
            scope: {

            }
        };

    });

}());