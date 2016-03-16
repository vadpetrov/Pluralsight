//tripEditorController.js

(function () {

    "use strict";

    var module = angular.module("app-trips");

    module.controller("tripEditorController",["$routeParams", "repo", tripEditorController]);
    ////////////////////////////////////////////////////////////////////
    function tripEditorController($routeParams, repository) {

        var vm = this;

        vm.tripName = $routeParams.tripName;
        vm.newStop = {};
        vm.stops = [];
        vm.errorMessage = "";
        vm.isBusy = true;
        /////////////////////////////////////////////////////////////////////////////////
        vm.tableHeaders = [
            { name: "Location", field: "name" },
            { name: "Arrival", field: "arrival"}];        
        /////////////////////////////////////////////////////////////////////////////////
        vm.sort = { by: "", column: {}};
        vm.sort.exec = function (header) {

            var setSortSettings = function (header, order) {
                vm.sort.by = (order ? header.field : "-" + header.field);
                vm.sort.column = { header: header, order: order };
            };

            if (vm.sort.column.header == null || (vm.sort.column.header.field != header.field))
                setSortSettings(header, true);
            else
                setSortSettings(header, !vm.sort.column.order);
        };
        vm.sort.exec(vm.tableHeaders[0]);
        /////////////////////////////////////////////////////////////////////////////////
        vm.addStop = function () {

            vm.isBusy = true;
            vm.errorMessage = "";

            repository.addStop(vm.tripName, vm.newStop)
                .then(function (data) {
                    vm.stops.push(data);
                    _showMap(vm.stops);
                    vm.newStop = {};
                }, function (err) {
                    vm.errorMessage = "Failed to add new stop. " + err;
                })
                .finally(function () {
                    vm.isBusy = false;
                });
        };
        /////////////////////////////////////////////////////////////////////////////////
        repository.getTripStops(vm.tripName)
            .then(
            function (data) {
                angular.copy(data, vm.stops);
                _showMap(vm.stops);
            },
            function (err) {
                vm.errorMessage = "Failed to load data: " + err;
            })
            .finally(function () {
                vm.isBusy = false;
            });
        /////////////////////////////////////////////////////////////////////////////////
    };


    ///http://wildermuth.com/2015/5/12/How_d_You_Build_That_Map
    function _showMap(stops) {
        if (stops && stops.length > 0)
        {
            var mapStops = _.map(stops, function (item) {

                return {
                    lat: item.latitude,
                    long: item.longitude,
                    info: item.name
                };
            });

            travelMap.createMap({
                stops: mapStops,
                selector: "#map",
                currentStop: 0,
                initialZoom: 5,
                icon: {           // Icon details
                    url: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAIAAABvrngfAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAadEVYdFNvZnR3YXJlAFBhaW50Lk5FVCB2My41LjExR/NCNwAAAA1JREFUGFdjoDNgYAAAAHIAAejt7scAAAAASUVORK5CYII=",
                    width: 3,
                    height: 3,
                },
                pastStroke: {     // Settings for the lines before the currentStop
                    color: '#190300',
                    opacity: 0.5,
                    weight: 2
                },
                futureStroke: {   // Settings for hte lines after the currentStop
                    color: '#D30000',
                    opacity: 0.6,
                    weight: 2
                },
                mapOptions: {     // Options for map (See GMaps for full list of options)
                    draggable: true,
                    scrollwheel: true,
                    disableDoubleClickZoom: true,
                    zoomControl: true
                }
            });
        }
    };

}());