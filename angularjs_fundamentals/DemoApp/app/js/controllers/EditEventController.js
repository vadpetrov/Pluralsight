(function () {


    "use strict";

    var module = angular.module("eventsApp");

    module.controller("EditEventController", EditEventController);

    function EditEventController($http, eventData) {

        var vm = this;

        vm.states = [
            { countryId: 1, name: "France - Mainland", desc: "some description" },
            { countryId: 3, name: "Gibraltar", desc: "some description" },
            { countryId: 4, name: "Malta", desc: "some description" }
        ];

        vm.selectedState1 = "3";
        vm.selectedState2 = vm.states[1];
        vm.selectedState3 = 3;
        vm.selectedState4 = vm.states[1];










        vm.testApi = Test;

        function Test()
        {
            getTrips()
                        .then(
                        function (data) {
                            console.log(data);
                            //vm.trips = data;
                        },
                        function (error) {
                            vm.errorMessage = "Failed to load data: " + error;
                        })
                        .finally(function () {
                          
                        });
        };

        function getTrips() {

            //return $http({
            //    url: "http://localhost:5000/api/trips",
            //    method: "GET",
            //    withCredentials: true,
            //    headers: { "Content-Type": "application/json; charset=utf-8" }
            //})
            //.then(function (response) {
            //    return response.data;
            //});

            //return $http({
            //    url: "http://localhost:5000/api/trips",
            //    method: "POST",
            //    data: { name: "Angular Trip 1" },
            //    withCredentials: true,
            //    headers: { "Content-Type": "application/json; charset=utf-8" }
            //})
            //.then(function (response) {
            //    return response.data;
            //});
            
            return $http.get("http://localhost:5000/api/trips", { withCredentials: true })
                           .then(function (response) {
                               return response.data;
                           });

        };
        
        vm.saveEvent = function (event, newEventForm) {
            console.log(newEventForm);

            if (newEventForm.$valid) {
                eventData.save(event)
                .$promise
                .then(function (reponse) { console.log("success", reponse)})
                .catch(function (reponse) { console.log("failure", reponse) })
                .finally(function () {
                    console.log("Save call end.")
                });
                    
            }
            else
                window.alert("we have a problem");
        };

        vm.cancelEvent = function(){        
            window.location = '/views/EventDetails.html';
        };
    };

}());