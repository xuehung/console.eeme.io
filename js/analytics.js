var ANALYTICS_CONFIG_BASE_URL = location.protocol + '//api.energyefficiency.me/v1/console/config';

var getAnalyticsConfigID = function() {
  var email, url;
  email = eemeConsole.auth.getEmail();
  url = ANALYTICS_CONFIG_BASE_URL + "/" + email;
  return eemeConsole.utils.get(url, {}, function(data) {
    return setAnalyticsConfigIDValue(data.config_id);
  });
};

var setAnalyticsConfigIDValue = function(analytics_config_id) {
  return $('#analytics-config-id').val(analytics_config_id);
};

var updateAnalyticsConfigIDBtnHandler = function(event) {
  var analytics_config_id, data, email, url;
  event.preventDefault();
  event.stopPropagation();
  email = eemeConsole.auth.getEmail();
  url = ANALYTICS_CONFIG_BASE_URL + "/" + email;
  analytics_config_id = $("[name=analytics-config-id-new]").val();
  data = {
    config_id: analytics_config_id
  };
  return eemeConsole.utils.post(url, data, function(data) {
    if (data.success === "yes") {
      alert("Update succeeded.");
      return setAnalyticsConfigIDValue(data.config_id);
    } else {
      return alert("Update failed: " + data.error);
    }
  });
};

var getApiKey = function() {
  var email, url;
  if (window['apikey'] != null) {
    return window['apikey'];
  }
  email = eemeConsole.auth.getEmail();
  url = eemeConsole.setting.API.CREDENTIAL_URL + "/" + email;
  return eemeConsole.utils.get(url, {}, function(data) {
    window['apikey'] = data.api_key;
    return load();
  });
};

var load = function() {
  console.log("load is called");
  $("#config-list tbody").html('<h2>Loading...</h2>');
  return eemeConsole.utils.get(ANALYTICS_CONFIG_BASE_URL, {}, function(data) {
    renderConfigList(data);
  });
};

var renderConfigList = function(data) {
  var i, item, listBody, results, row;
  listBody = $("#config-list tbody");
  console.log(data.data);
  listBody.html('');
  i = 0;
  results = [];
  while (i < data.data.length) {
    item = data.data[i];
    row = '<td>' + item.id + '</td>';
    row += '<td>' + item.interval + '</td>';
    row += '<td>' + item.module + '</td>';
    row += '<td>' + item.region + '</td>';
    row += '<td>' + item.resource + '</td>';
    row += '<td>' + item.space + '</td>';
    row += '<td>' + item.track + '</td>';
    row += '<td>' + item.units + '</td>';
    row += '<td>' + item.usecase + '</td>';
    row = '<tr>' + row + '</tr>';
    listBody.append(row);
    results.push(i++);
  }
  return results;
};

$(document).ready(function() {
  window['cache'] = {};
  getAnalyticsConfigID();
  getApiKey();
  return $('#update-analytics-config-id-btn').click(updateAnalyticsConfigIDBtnHandler);
});
