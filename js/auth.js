var cookie_console_token = 'console_token';

var cookie_email = 'email';

var hostname = window.location.hostname;

if (hostname.indexOf('www') === 0) {
  hostname = hostname.substring(3);
}

var options = {
  domain: hostname,
  expires: 1
};

var auth = {
  loginRequired: function() {
    var currrentAddr, isLogin;
    currrentAddr = window.location.href.replace(/\/+$/, "");
    isLogin = Cookies.get(cookie_console_token);
    if (isLogin) {
      if (currrentAddr !== eemeConsole.setting.CONSOLE.LOGIN_URL && currrentAddr !== eemeConsole.setting.CONSOLE.SIGNUP_URL) {

      } else {
        return window.location.replace(eemeConsole.setting.CONSOLE.BASE_URL);
      }
    } else if (currrentAddr !== eemeConsole.setting.CONSOLE.LOGIN_URL && currrentAddr !== eemeConsole.setting.CONSOLE.SIGNUP_URL) {
      return window.location.replace(eemeConsole.setting.CONSOLE.LOGIN_URL);
    }
  },
  login: function(email, token) {
    Cookies.set(cookie_console_token, token, options);
    Cookies.set(cookie_email, email, options);
    return window.location.replace(eemeConsole.setting.CONSOLE.BASE_URL);
  },
  logout: function() {
    Cookies.remove(cookie_console_token, options);
    Cookies.remove(cookie_email, options);
    return window.location.replace(eemeConsole.setting.CONSOLE.LOGIN_URL);
  },
  forceLogout: function() {
    if (window.location.href === eemeConsole.setting.CONSOLE.LOGIN_URL) {
      alert('login failed');
      return $("[name='password']").val("");
    } else {
      alert('not authorized anymore');
      eemeConsole.auth.logout();
      return window.location.replace(eemeConsole.setting.CONSOLE.LOGIN_URL);
    }
  },
  getToken: function() {
    return Cookies.get(cookie_console_token);
  },
  getEmail: function() {
    return Cookies.get(cookie_email);
  }
};

window.eemeConsole.auth = auth;

eemeConsole.auth.loginRequired();
