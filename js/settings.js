var PROTOCOL = location.protocol;

var global = {
  API_BASE_URL: PROTOCOL + '//api.energyefficiency.me/v1/console',
  CONSOLE_BASE_URL: window.location.origin
};

if (window.location.hostname === "127.0.0.1" || window.location.hostname === "localhost") {
  global.CONSOLE_BASE_URL = global.CONSOLE_BASE_URL + "/console";
}

var setting = {
  API: {
    LOGIN_URL: global.API_BASE_URL + '/login',
    CREDENTIAL_URL: global.API_BASE_URL + '/credential',
    CALLBACKURL_URL: global.API_BASE_URL + '/callback',
    SSHKEY_URL: global.API_BASE_URL + '/ssh',
    SIGNUP_URL: global.API_BASE_URL + '/signup',
    FEEDBACK_URL: global.API_BASE_URL + '/feedback'
  },
  CONSOLE: {
    BASE_URL: global.CONSOLE_BASE_URL,
    LOGIN_URL: global.CONSOLE_BASE_URL + '/login',
    SIGNUP_URL: global.CONSOLE_BASE_URL + '/signup'
  }
};

var console = {
  global: global,
  setting: setting
};

window.eemeConsole = console;

$(document).on("click", ".close", function(event) {
  return $(this).parent().hide();
});

$(document).on("click", "#feedback-btn", function(event) {
  return $("#feedback-div").show();
});

$(document).on("click", "#feedback-submit-btn", function(event) {
  var data, feedback, purpose, url;
  event.preventDefault();
  purpose = $("input[name='purpose']").val();
  feedback = $("textarea[name='feedback']").val();
  if (purpose === "" && feedback === "") {
    alert("Please don't leave all fields empty.");
    return;
  }
  url = eemeConsole.setting.API.FEEDBACK_URL;
  data = {
    'purpose': purpose,
    'feedback': feedback
  };
  return $.post(url, data, function(data) {
    alert("Thanks for your feedback!");
    $("input[name='purpose']").val("");
    $("textarea[name='feedback']").val("");
    return $("#feedback-div").hide();
  }).error(function() {
    return alert("Sorry! Something went wrong.");
  });
});
