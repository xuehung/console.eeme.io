var setCallbackUrlUI = function(callback_url) {
  $('#callback-url').val(callback_url);
  $('#callback-url').removeAttr('disabled');
  return $('#callback-url').removeAttr('readonly');
};

var setAccountInfoUI = function(api_key, test_api_key) {
  $('#credential-api-key').val(api_key);
  $('#credential-test-api-key').val(test_api_key);
  if (api_key !== 'N/A') {
    $('#credential-api-key').removeAttr('disabled');
  }
  if (test_api_key !== 'N/A') {
    return $('#credential-test-api-key').removeAttr('disabled');
  }
};

var tryFetchLatestInfo = function() {
  var email, url;
  email = eemeConsole.auth.getEmail();
  url = eemeConsole.setting.API.CREDENTIAL_URL + "/" + email;
  return eemeConsole.utils.get(url, {}, function(data) {
    if ($('#credential-client-id').val() === data.service_account[0].client_id) {
      return setTimeout(tryFetchLatestInfo, 1000);
    } else {
      return getCredentials();
    }
  });
};

var updateCallbackUrlBtnHandler = function(event) {
  var callback_url, data, email, url;
  event.preventDefault();
  event.stopPropagation();
  email = eemeConsole.auth.getEmail();
  url = eemeConsole.setting.API.CALLBACKURL_URL + "/" + email;
  callback_url = $("[name=callback-url]").val();
  data = {
    callback_url: callback_url
  };
  return eemeConsole.utils.post(url, data, function(data) {
    if (data.callback_url === callback_url) {
      return alert("Update successfully");
    }
  });
};

var createAccountBtnHandler = function(event) {
  var email, url;
  event.preventDefault();
  event.stopPropagation();
  email = eemeConsole.auth.getEmail();
  url = eemeConsole.setting.API.CREDENTIAL_URL + "/" + email;
  return eemeConsole.utils.post(url, {}, function(data) {
    return setAccountInfoUI(data.api_key, data.test_api_key);
  });
};

var getCredentials = function() {
  var email, url;
  email = eemeConsole.auth.getEmail();
  url = eemeConsole.setting.API.CREDENTIAL_URL + "/" + email;
  return eemeConsole.utils.get(url, {}, function(data) {
    var api_key, test_api_key;
    api_key = 'N/A';
    test_api_key = 'N/A';
    if (data.api_key !== "") {
      api_key = data.api_key;
    }
    if (data.test_api_key !== "") {
      test_api_key = data.test_api_key;
    }
    return setAccountInfoUI(api_key, test_api_key);
  });
};

var getCallbackUrl = function() {
  var email, url;
  email = eemeConsole.auth.getEmail();
  url = eemeConsole.setting.API.CALLBACKURL_URL + "/" + email;
  return eemeConsole.utils.get(url, {}, function(data) {
    var callback_url;
    callback_url = 'N/A';
    if (data.callback_url !== "") {
      callback_url = data.callback_url;
    }
    return setCallbackUrlUI(callback_url);
  });
};

$(document).ready(function() {
  $('#create-service-account-btn').click(createAccountBtnHandler);
  $('#update-callback-url-btn').click(updateCallbackUrlBtnHandler);
  getCredentials();
  return getCallbackUrl();
});
