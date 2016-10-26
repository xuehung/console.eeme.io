var loginBtnHandler = function(event) {
  var data, email, password, url;
  event.preventDefault();
  event.stopPropagation();
  email = $("[name='email']").val();
  password = $("[name='password']").val();
  url = eemeConsole.setting.API.LOGIN_URL + "/" + email;
  data = {
    password: password
  };
  return eemeConsole.utils.post(url, data, function(data) {
    return eemeConsole.auth.login(email, data.token);
  });
};

$(document).ready(function() {
  return $('#login-btn').click(loginBtnHandler);
});
