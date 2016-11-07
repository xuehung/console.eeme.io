---
---

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


loginBtnHandler = (event) ->
    event.preventDefault()
    event.stopPropagation()
    email = $("[name='email']").val()
    password = $("[name='password']").val()
    url = eemeConsole.setting.API.LOGIN_URL + "/" + email
    data =
        password: password
    eemeConsole.utils.post url, data, (data) ->
        eemeConsole.auth.login(email, data.token)

$(document).ready ->
    $('#login-btn').click(loginBtnHandler)
