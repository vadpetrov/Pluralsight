"use strict";

var UserModel = (function () {

    function model(lastName, firstName) {
        this.lastName = lastName;
        this.firstName = firstName;
    }
    return model;
}());