var API_BASE_URL = location.protocol + '//api.energyefficiency.me/v1/home';

var ajax = function(method, url, data, callbackIfData) {
  return $.ajax({
    type: method,
    url: url,
    data: data,
    success: function(data, textStatus) {
      return callbackIfData(data);
    },
    beforeSend: function(request) {
      return request.setRequestHeader("Authorization", 'Bearer ' + window['apikey']);
    },
    error: function(jqXHR, textStatus) {
      return alert("Failed: " + textStatus);
    }
  });
};

var get = function(url, data, callbackIfData) {
  return ajax('get', url, data, callbackIfData);
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
  $("#home-list tbody").html('<h2>Loading...</h2>');
  return get(API_BASE_URL, {}, function(data) {
    renderHomeList(data);
  });
};

var renderHomeList = function(data) {
  var date, i, item, listBody, results, row, status;
  listBody = $("#home-list tbody");
  console.log(data.data);
  listBody.html('');
  i = 0;
  results = [];
  while (i < data.data.length) {
    item = data.data[i];
    row = '<td>' + i + '</td>';
    date = new Date(item.created_at + ' UTC');
    row += '<td>' + date.toLocaleString() + '</td>';
    row += '<td>' + item.id + '</td>';
    row += '<td>' + item.filename + '</td>';
    status = '<span class="label label-warning">Unknown</span>';
    if (item.status === 'new') {
      status = '<span class="label label-info">Received</span>';
    }
    if (item.status === 'validated') {
      status = '<span class="label label-info">Validated</span>';
    }
    if (item.status === 'completed') {
      status = '<span class="label label-success">Success</span>';
    }
    if (item.status === 'error') {
      status = '<span class="label label-danger">Processing</span>';
    }
    if (item.status === 'validation error') {
      status = '<span class="label label-success">Validation Error</span>';
    }
    if (item.status === 'processing error') {
      status = '<span class="label label-success">Processing Error</span>';
    }
    row += '<td>' + status + '</td>';
    row += '<td>' + item.process_time + '</td>';
    if (item.status === 'completed') {
      row += '<td><a href="#" class="showhome" homeid="' + item.id + '">show</a></td>';
      row += '<td><a href="#" class="downloadhome" homeid="' + item.id + '" filename="' + item.filename + '">download</a></td>';
    } else {
      row += '<td></td>';
      row += '<td></td>';
    }
    row = '<tr>' + row + '</tr>';
    listBody.append(row);
    results.push(i++);
  }
  return results;
};

var downloadAll = function(data) {
  var i, item, results;
  i = 0;
  results = [];
  while (i < data.data.length) {
    item = data.data[i];
    if (item.status === 'completed') {
      console.log(i);
      console.log(item.id);
      console.log(item.filename);
      downloadHomeData(item.id, item.filename);
    }
    results.push(i++);
  }
  return results;
};

var downloadHomeData = function(homeid, orifilename) {
  var url;
  if ((window['cache'][homeid] != null)) {
    return saveHomeData(homeid, orifilename, window['cache'][homeid]);
  } else {
    url = API_BASE_URL + "/" + homeid;
    return get(url, {}, function(data) {
      window['cache'][homeid] = data;
      return saveHomeData(homeid, orifilename, data);
    });
  }
};

var loadHomeData = function(homeid) {
  var url;
  window['curr_homeid'] = homeid;
  if ((window['cache'][homeid] != null)) {
    console.log("Get " + homeid + " from cache");
    return renderHomeData(homeid, window['cache'][homeid]);
  } else {
    console.log(homeid + " is not in cache");
    url = API_BASE_URL + "/" + homeid;
    return get(url, {}, function(data) {
      window['cache'][homeid] = data;
      return renderHomeData(homeid, data);
    });
  }
};

var saveHomeData = function(homeid, orifilename, data) {
  var addClientId, clientId, content, fields, filename, header, headers, i, item, j, len1, link, uriContent;
  clientId = data.client_id;
  content = "";
  addClientId = clientId.length !== 0;
  if (addClientId) {
    content += "client_id,";
  }
  headers = getHeaders(data.data[0]);
  content += headers.join() + '\n';
  i = 0;
  while (i < data.data.length) {
    item = data.data[i];
    if (addClientId) {
      content += clientId + ",";
    }
    fields = [];
    for (j = 0, len1 = headers.length; j < len1; j++) {
      header = headers[j];
      fields.push(item[header]);
    }
    content += fields.join();
    content += "\n";
    i++;
  }
  content = content.replace(RegExp(' ', 'g'), '');
  uriContent = "data:application/octet-stream," + encodeURIComponent(content);
  filename = orifilename + "-result.csv";
  link = document.createElement('a');
  link.setAttribute('href', uriContent);
  link.setAttribute('download', filename);
  return link.click();
};

var getHeaders = function(obj) {
  var headers, key;
  headers = ['timestamp'];
  for (key in obj) {
    if (key !== 'timestamp') {
      headers.push(key);
    }
  }
  return headers;
};

var renderHomeData = function(homeid, data) {
  var addClientId, clientId, header, headers, i, item, j, k, len1, len2, row, tableBody, tableHead;
  if (homeid !== window['curr_homeid']) {
    console.log("Do not need " + homeid + " anymore. Current homeid = " + window['curr_homeid']);
    return;
  }
  console.log("Render " + homeid);
  clientId = data.client_id;
  addClientId = clientId.length !== 0;
  $("#homeid").html(homeid);
  tableHead = $("#homedata-table thead");
  tableHead.html('');
  row = '<th>#</th>';
  if (addClientId) {
    row += '<th>Client Id</th>';
  }
  headers = getHeaders(data.data[0]);
  for (j = 0, len1 = headers.length; j < len1; j++) {
    header = headers[j];
    row += '<th>' + header.replace(/_/g, ' ') + '</th>';
  }
  row = '<tr>' + row + '</tr>';
  tableHead.append(row);
  tableBody = $("#homedata-table tbody");
  console.log(data.data);
  tableBody.html('');
  i = 0;
  while (i < data.data.length) {
    item = data.data[i];
    row = '<td>' + i + '</td>';
    if (addClientId) {
      row += '<td>' + clientId + '</td>';
    }
    for (k = 0, len2 = headers.length; k < len2; k++) {
      header = headers[k];
      row += '<td>' + item[header] + '</td>';
    }
    row = '<tr>' + row + '</tr>';
    tableBody.append(row);
    i++;
  }
  return $('#home-modal').foundation('reveal', 'open');
};

var multiupload = function(i, len) {
  var config_id_override, formData, optional_parameters, parser_override, preprocess_override;
  if (i >= len) {
    alert('Upload ' + window.success + ' files successfully, ' + window.fail + ' failed');
    $('.progress').fadeOut();
    load();
    return;
  }
  formData = new FormData();
  formData.append('usage', document.getElementById('file').files[i]);
  config_id_override = $("[name=config-id]").val();
  parser_override = $("[name=parser]").val();
  preprocess_override = $("[name=preprocess]").val();
  optional_parameters = $("[name=optional-parameters]").val();
  if (config_id_override.length > 0) {
    formData.append('config_id', config_id_override);
  }
  if (parser_override.length > 0) {
    formData.append('parser', parser_override);
  }
  if (preprocess_override.length > 0) {
    formData.append('preprocess', preprocess_override);
  }
  if (optional_parameters.length > 0) {
    formData.append('optional_parameters', optional_parameters);
  }
  return $.ajax({
    url: location.protocol + '//api.energyefficiency.me/v1/home',
    type: 'POST',
    beforeSend: function(request) {
      var percent, total, value;
      request.setRequestHeader('Authorization', 'Bearer ' + window['apikey']);
      value = i + 0.5;
      total = len;
      percent = value * 100 / total;
      console.log(percent);
      $('.meter').width(percent + '%');
    },
    success: function() {
      window.success++;
    },
    complete: function() {
      var percent, total, value;
      value = i + 1;
      total = len;
      percent = value * 100 / total;
      console.log(percent);
      $('.meter').width(percent + '%');
      multiupload(i + 1, total);
    },
    error: function(jqXHR) {
      var msg;
      msg = JSON.parse(jqXHR.responseText).error.message;
      window.fail++;
    },
    data: formData,
    contentType: false,
    processData: false
  });
};

var uploadFile = function() {
  var len;
  window.success = 0;
  window.fail = 0;
  len = document.getElementById('file').files.length;
  $('.meter').width('0%');
  $('.progress').show();
  multiupload(0, len);
};

var progressHandlingFunction = function(e) {
  var percent, total, value;
  if (e.lengthComputable) {
    value = e.loaded;
    total = e.total;
    percent = value * 100 / total;
    console.log(percent);
    $('.meter').width(percent + '%');
  }
};

$(document).ready(function() {
  window['cache'] = {};
  getApiKey();
  $('#reload-btn').click(load);
  $('button.file-upload').click(function(event) {
    event.preventDefault();
    $('input.file-input').click();
  });
  $('input.file-input').click(function(event) {
    event.stopPropagation();
    this.value = null;
  });
  $(document).on('click', 'a.showhome', function() {
    var homeid;
    homeid = $(this).attr('homeid');
    return loadHomeData(homeid);
  });
  $(document).on('click', 'a.downloadhome', function() {
    var filename, fileprefix, homeid;
    homeid = $(this).attr('homeid');
    filename = $(this).attr('filename');
    fileprefix = filename.split('.')[0];
    return downloadHomeData(homeid, fileprefix);
  });
  return $('input.file-input').change(function(event, numFiles, label) {
    return uploadFile();
  });
});
