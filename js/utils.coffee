---
---

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ajax = (method, url, data, callbackIfData) ->
    $.ajax
        type: method
        url: url
        data: data
        success: (data) ->
            callbackIfData(data)
        statusCode:
            401: () ->
                eemeConsole.auth.forceLogout()
        beforeSend: (request) ->
            if method == 'post'
                $('#ajax-loader').show()
            token = eemeConsole.auth.getToken()
            if token
                request.setRequestHeader("Authorization", token)
        complete: () ->
            if method == 'post'
                $('#ajax-loader').hide()
        error: (jqXHR, textStatus, errorThrown ) ->
            alert("Failed: " + textStatus)

consoleAlert = (message) ->
    html = '<div data-alert class="alert-box">'+message+'<a href="#" class="close">&times;</a></div>'
    $('#main').prepend(html)


utils =
    get: (url, data, callbackIfData) ->
        ajax('get', url, data, callbackIfData)
    post: (url, data, callbackIfData) ->
        ajax('post', url, data, callbackIfData)
    alert: consoleAlert

window.eemeConsole.utils = utils

