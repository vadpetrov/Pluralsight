(function(){
    "use strict";

    var eventsApp = angular.module("eventsApp", ["ngRoute","ngResource"]);


    //eventsApp.config(function ($routeProvider) {});

    eventsApp.config(appRouting);

    eventsApp.run(function ($rootScope, $templateCache) {
        $rootScope.$on('$routeChangeStart', function (event, next, current) {
            if (typeof (current) !== 'undefined') {
                console.log("Remove cache 1.")
                $templateCache.remove(current.templateUrl);
            }
        });
    });

    //eventsApp.run(function ($rootScope, $templateCache) {
    //    $rootScope.$on('$viewContentLoaded', function () {
    //        console.log("Remove cache 2.")
    //        $templateCache.removeAll();
    //    });
    //});


    function appRouting($routeProvider, $locationProvider) {

        $routeProvider
        .when("/",{
            template: "Application Base"
        })
        .when("/newEvent", {
            templateUrl: "templates/NewEvent.html",
            contoroller: "EditEventController",
            controllerAs: "vm"
        })
        .when("/events", {
            templateUrl: "templates/EventList.html",
            controller: "EventListController"
        })
        .when("/event/:eventId", {
            templateUrl: "templates/EventDetails.html",
            controller: "EventController",
            controllerAs: "vm",
            foo: "bar",
            resolve: {//delay page loading until server data is loaded. handle slow loading pages
                event: function ($route, eventData) {                    
                    return eventData.getEvent3($route.current.pathParams.eventId).$promise;
                }
            }
        })
        .when('/sampleDirective',
            {
                templateUrl: 'templates/SampleDirective.html',
                controller: 'SampleDirectiveController'
            })
        .otherwise({ redirectTo: "/" });


        //use routeProvider without # sign in url
        $locationProvider.html5Mode(true);


        //$locationProvider.html5Mode({
        //    enabled: true,
        //    requireBase: false
        //});
    };

}());


