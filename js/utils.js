var ajax = function(method, url, data, callbackIfData) {
  return $.ajax({
    type: method,
    url: url,
    data: data,
    success: function(data) {
      return callbackIfData(data);
    },
    statusCode: {
      401: function() {
        return eemeConsole.auth.forceLogout();
      }
    },
    beforeSend: function(request) {
      var token;
      if (method === 'post') {
        $('#ajax-loader').show();
      }
      token = eemeConsole.auth.getToken();
      if (token) {
        return request.setRequestHeader("Authorization", token);
      }
    },
    complete: function() {
      if (method === 'post') {
        return $('#ajax-loader').hide();
      }
    },
    error: function(jqXHR, textStatus, errorThrown) {
      return alert("Failed: " + textStatus);
    }
  });
};

consoleAlert = function(message) {
  var html;
  html = '<div data-alert class="alert-box">' + message + '<a href="#" class="close">&times;</a></div>';
  return $('#main').prepend(html);
};

var utils = {
  get: function(url, data, callbackIfData) {
    return ajax('get', url, data, callbackIfData);
  },
  post: function(url, data, callbackIfData) {
    return ajax('post', url, data, callbackIfData);
  },
  alert: consoleAlert
};

window.eemeConsole.utils = utils;
