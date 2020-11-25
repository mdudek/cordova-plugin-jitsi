var exec = require('cordova/exec');

exports.join = function(serverUrl, room, subject, userName, audioOnly, success, error) {
    exec(success, error, "JitsiPlugin", "join", [serverUrl, room, !!audioOnly, subject, userName]);
};

exports.destroy = function(success, error) {
    exec(success, error, "JitsiPlugin", "destroy", []);
};
