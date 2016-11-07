# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ANALYTICS_CONFIG_BASE_URL = location.protocol + '//api.energyefficiency.me/v1/console/config'

getAnalyticsConfigID = () ->
    # get credentials
    email = eemeConsole.auth.getEmail()
    url = ANALYTICS_CONFIG_BASE_URL + "/" + email
    eemeConsole.utils.get url, {}, (data) ->
        setAnalyticsConfigIDValue(data.config_id)

setAnalyticsConfigIDValue = (analytics_config_id) ->
    $('#analytics-config-id').val(analytics_config_id)

updateAnalyticsConfigIDBtnHandler = (event) ->
    event.preventDefault()
    event.stopPropagation()
    email = eemeConsole.auth.getEmail()
    url = ANALYTICS_CONFIG_BASE_URL + "/" + email
    analytics_config_id = $("[name=analytics-config-id-new]").val()
    data =
        config_id: analytics_config_id
    eemeConsole.utils.post url, data, (data) ->
        if data.success == "yes"
            alert("Update succeeded.")
            setAnalyticsConfigIDValue(data.config_id)
        else
            alert("Update failed: " + data.error)

getApiKey = ->
    if window['apikey']?
        return window['apikey']
    email = eemeConsole.auth.getEmail()
    url = eemeConsole.setting.API.CREDENTIAL_URL + "/" + email
    eemeConsole.utils.get url, {}, (data) ->
        window['apikey'] = data.api_key
        load()

load = ->
    console.log("load is called")
    $("#config-list tbody").html('<h2>Loading...</h2>')
    eemeConsole.utils.get ANALYTICS_CONFIG_BASE_URL, {}, (data) ->
        renderConfigList(data)
        return

renderConfigList = (data) ->
    listBody = $("#config-list tbody")
    console.log(data.data)
    listBody.html('')
    i = 0
    while i < data.data.length
        item = data.data[i]
        row = '<td>' + item.id + '</td>'
        row += '<td>' + item.interval + '</td>'
        row += '<td>' + item.module + '</td>'
        row += '<td>' + item.region + '</td>'
        row += '<td>' + item.resource + '</td>'
        row += '<td>' + item.space + '</td>'
        row += '<td>' + item.track + '</td>'
        row += '<td>' + item.units + '</td>'
        row += '<td>' + item.usecase + '</td>'
        row = '<tr>' + row + '</tr>'
        listBody.append(row)
        i++

$(document).ready ->
    window['cache'] = {}
    getAnalyticsConfigID()
    getApiKey()
    # bind handler
    $('#update-analytics-config-id-btn').click(updateAnalyticsConfigIDBtnHandler)
