//tripsController.js
(function () {

    "use strict";

    var module = angular.module("app-trips");
    module.controller("tripsController", ["repo", tripsController]);    
    ////////////////////////////////////////////////////////////////////
    function tripsController(repository) {

        var vm = this;
        ////////////////////////////////////////////////////////////////////                       
        vm.trips = [];        
        vm.newTrip = {};
        vm.errorMessage = "";
        vm.isBusy = true;
        ////////////////////////////////////////////////////////////////////        
        repository.getTrips()
            .then(
            function (data) {                
                angular.copy(data, vm.trips);
                //vm.trips = data;
            },
            function (error) {
                vm.errorMessage = "Failed to load data: " + error;
            })
            .finally(function () {
                vm.isBusy = false;
            });
        ////////////////////////////////////////////////////////////////////
        vm.addTrip = function () {
            vm.isBusy = true;
            vm.errorMessage = "";

            repository.addTrip(vm.newTrip)
                .then(function (data) {
                    vm.trips.push(data);
                    vm.newTrip = {};
                }, function (error) {
                    vm.errorMessage = "Failed to save new trip.";
                })
                .finally(function () {
                    vm.isBusy = false;
                });
        };
        ////////////////////////////////////////////////////////////////////
        vm.tripsTemplate = "/views/trips_template.html";
        vm.sortOrder = ["-created","name"];
        vm.name = "Vadim";
    };
}());