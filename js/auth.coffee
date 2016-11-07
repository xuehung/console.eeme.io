---
---

# before the page is loaded and ready

cookie_console_token = 'console_token'
cookie_email = 'email'

# get options for cookie
hostname = window.location.hostname
if hostname.indexOf('www') == 0
    # remove 'www' in the beginning of the hostname
    hostname = hostname.substring(3)
# Expires in one day
options = {domain: hostname, expires: 1}

auth =
    loginRequired: () ->
        currrentAddr = window.location.href.replace(/\/+$/, "")
        isLogin = Cookies.get(cookie_console_token)
        if isLogin
            if currrentAddr != eemeConsole.setting.CONSOLE.LOGIN_URL && currrentAddr != eemeConsole.setting.CONSOLE.SIGNUP_URL
                return
            else
                window.location.replace(eemeConsole.setting.CONSOLE.BASE_URL)
        else if currrentAddr != eemeConsole.setting.CONSOLE.LOGIN_URL && currrentAddr != eemeConsole.setting.CONSOLE.SIGNUP_URL
            window.location.replace(eemeConsole.setting.CONSOLE.LOGIN_URL)

    login: (email, token) ->
        Cookies.set(cookie_console_token, token, options)
        Cookies.set(cookie_email, email, options)
        window.location.replace(eemeConsole.setting.CONSOLE.BASE_URL)

    logout: () ->
        Cookies.remove(cookie_console_token, options)
        Cookies.remove(cookie_email, options)
        window.location.replace(eemeConsole.setting.CONSOLE.LOGIN_URL)

    forceLogout: () ->
        if window.location.href == eemeConsole.setting.CONSOLE.LOGIN_URL
            alert('login failed')
            $("[name='password']").val("")
        else
            alert('not authorized anymore')
            eemeConsole.auth.logout()
            window.location.replace(eemeConsole.setting.CONSOLE.LOGIN_URL)
    getToken: () ->
        return Cookies.get(cookie_console_token)
    getEmail: () ->
        return Cookies.get(cookie_email)

window.eemeConsole.auth = auth

# user should login to access this page
eemeConsole.auth.loginRequired()
