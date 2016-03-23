(function () {

    "use strict";

    var module = angular.module("eventsApp");
    module.controller("EventController", EventController);   
    

    function EventController($scope, $sce, eventData, $log) {

        var vm = this;

        vm.trips = [{}];
        //vm.event = null;


        //vm.event = eventData.event;

        //using $resource ngResource
        //vm.event = eventData.getEvent3();

        //eventData.getEvent3()
        //.$promise.then(
        //function (event) {
        //    vm.event = event;
        //    console.log(event);
        //},
        //function (error) {
        //    console.log("Failed to load data.");
        //    console.log(error);
        //});

        eventData.getEvent3()
        .$promise.then(function (event) {
                vm.event = event;
                console.log(event);
        })
        .catch(function (error) {
            console.log("Failed to load data.");
            console.log(error);
        })
        .finally(function () {
           console.log("Get events call: END");
        });




        


        //eventData.getEvent2()
        //.success(function (event) {
        //    vm.event = event;
        //})
        //.error(function (data, status, headers, config) {
        //    $log.warn("get event error");
        //    $log.warn(data, status, headers(), config);
        //});



        //eventData.getEvent(function (event) {
        //    vm.event = event;
        //});

        //eventData.getEvent1()
        //.then(
        //    function (data) {
        //        vm.event = data;
        //    },
        //    function (error) {
        //        console.log("Failed to load data.");
        //        console.log(error);
        //    })
        //.finally(function () {
        //   console.log("Get events call: END");
        //});



        vm.snippet = "<span style='color:red'>hi there</span>";
        vm.snippetSafe = $sce.trustAsHtml("<span style='color:red'>hi there</span>");

        vm.boolValue = true;
        vm.mystyle = { color: "green" };
        vm.myclass = "blue";
        vm.buttonDisabled = true;
        vm.sortorder = "name";
        //vm.sortorder = "[-upVoteCount,name]";

        vm.toJsDate = function (str) {
            if (!str) return null;
            return new Date(str);
        };

        vm.upVoteSession = function (session) {
            session.upVoteCount++;
        };

        vm.downVoteSession = function (session) {
            session.upVoteCount--;
        }
    };

}());