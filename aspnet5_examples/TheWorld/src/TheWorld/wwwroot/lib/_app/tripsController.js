!function(){"use strict";function r(r){var e=this;e.trips=[],e.newTrip={},e.errorMessage="",e.isBusy=!0,r.getTrips().then(function(r){angular.copy(r,e.trips)},function(r){e.errorMessage="Failed to load data: "+r})["finally"](function(){e.isBusy=!1}),e.addTrip=function(){e.isBusy=!0,e.errorMessage="",r.addTrip(e.newTrip).then(function(r){e.trips.push(r),e.newTrip={}},function(r){e.errorMessage="Failed to save new trip. - "+r.data.message})["finally"](function(){e.isBusy=!1})},e.tripsTemplate="/views/trips_template.html",e.sortOrder=["-created","name"],e.name="Vadim"}var e=angular.module("app-trips");e.controller("tripsController",["repo",r])}();