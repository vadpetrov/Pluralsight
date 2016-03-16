//repo.js

(function () {

    var repo = function ($http) {
        ////////////////////////////////////////////////////////////////////////////
        function getTrips() {

            return $http.get("/api/trips")
                .then(function (response){                    
                    return response.data;
                });
        };
        ////////////////////////////////////////////////////////////////////////////
        function addTrip(trip) {

            return $http.post("/api/trips", trip)
            .then(function (response){
                return response.data;
            });
        };
        ////////////////////////////////////////////////////////////////////////////
        function getTripStops(tripName) {

            return $http.get("/api/trips/" + tripName + "/stops")
                .then(function (response) {
                    return response.data;
                });
        };
        ////////////////////////////////////////////////////////////////////////////
        function addStop(tripName, stop) {

            return $http.post("/api/trips/" + tripName + "/stops", stop)
            .then(function (response) {
                return response.data;
            });
        };
        ////////////////////////////////////////////////////////////////////////////
        return {
            getTrips: getTrips,
            getTripStops: getTripStops,
            addTrip: addTrip,
            addStop: addStop
        };
    };


    var module = angular.module("app-trips");
    module.factory("repo", repo);

}());