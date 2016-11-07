---
---

API_BASE_URL = location.protocol + '//api.energyefficiency.me/v1/home'
ajax = (method, url, data, callbackIfData) ->
    console.log(window['apikey'])
    $.ajax
        type: method
        url: url
        data: data
        success: (data, textStatus) ->
            callbackIfData(data)
        beforeSend: (request) ->
             request.setRequestHeader("Authorization", 'Bearer ' + window['apikey'])
        error: (jqXHR, textStatus) ->
            alert("Failed: " + textStatus)

get = (url, data, callbackIfData) ->
    ajax('get', url, data, callbackIfData)

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
    $("#home-list tbody").html('<h2>Loading...</h2>')
    get API_BASE_URL, {}, (data) ->
        renderHomeList(data)
        return

renderHomeList = (data) ->
     listBody = $("#home-list tbody")
     console.log(data.data)
     listBody.html('')
     i = 0
     #for (i = 0 ; i < data.data.length ; i++)
     while i < data.data.length
         item = data.data[i]
         row = '<td>' + i + '</td>'
         date = new Date(item.created_at+' UTC')
         row += '<td>' + date.toLocaleString() + '</td>'
         row += '<td>' + item.id + '</td>'
         row += '<td>' + item.filename + '</td>'
         status = '<span class="label label-warning">Unknown</span>'
         if (item.status == 'new')
             status = '<span class="label label-info">Received</span>'
         if (item.status == 'validated')
             status = '<span class="label label-info">Validated</span>'
         if (item.status == 'completed')
            status = '<span class="label label-success">Success</span>'
         if (item.status == 'error')
            #change the frontend status to processing for TXU case 
            status = '<span class="label label-danger">Processing</span>'
         if (item.status == 'validation error')
            status = '<span class="label label-success">Validation Error</span>'
         if (item.status == 'processing error')
            status = '<span class="label label-success">Processing Error</span>'
         row += '<td>' + status + '</td>'
         row += '<td>' + item.process_time + '</td>'
         if (item.status == 'completed')
             row += '<td><a href="#" class="showhome" homeid="' + item.id + '">show</a></td>'
             row += '<td><a href="#" class="downloadhome" homeid="' + item.id + '" filename="' + item.filename + '">download</a></td>'
         else
            row += '<td></td>'
            row += '<td></td>'
         row = '<tr>' + row + '</tr>'
         listBody.append(row)
         i++

downloadAll = (data) ->
    i = 0
    while i < data.data.length
         item = data.data[i]
         if (item.status == 'completed')
            console.log(i)
            console.log(item.id)
            console.log(item.filename)
            downloadHomeData(item.id, item.filename)
         i++

downloadHomeData = (homeid, orifilename) ->
    if (window['cache'][homeid]?)
        saveHomeData(homeid, orifilename, window['cache'][homeid])
    else
        url = API_BASE_URL + "/" + homeid
        get url, {}, (data) ->
            window['cache'][homeid] = data
            saveHomeData(homeid, orifilename, data)

loadHomeData = (homeid) ->
    window['curr_homeid'] = homeid
    if (window['cache'][homeid]?)
        console.log("Get " + homeid + " from cache")
        renderHomeData(homeid, window['cache'][homeid])
    else
        console.log(homeid + " is not in cache")
        url = API_BASE_URL + "/" + homeid
        get url, {}, (data) ->
            window['cache'][homeid] = data
            renderHomeData(homeid, data)

saveHomeData = (homeid, orifilename, data) ->
    clientId = data.client_id
    content = ""
    addClientId = clientId.length != 0
    if addClientId
        content += "client_id,"
    
    headers = getHeaders(data.data[0])
    content += headers.join() + '\n'
        
    i = 0
    while i < data.data.length
        item = data.data[i]
        if addClientId
            content += (clientId + ",")
        fields = []
        for header in headers
            fields.push item[header]
        content += fields.join()    
        content += "\n"
        i++
    # Remove all spaces from content
    # content = content.replace(RegExp(' ', 'g'), '')
    uriContent = "data:application/octet-stream," + encodeURIComponent(content)
    #newWindow = window.open(uriContent, 'result')
    #location.href = uriContent
    filename = orifilename + "-result.csv"
    link = document.createElement('a')
    link.setAttribute 'href', uriContent
    link.setAttribute 'download', filename
    link.click()

getHeaders = (obj) ->
    headers = ['timestamp']
    for key of obj 
        if key != 'timestamp'
            headers.push(key)
    return headers

renderHomeData = (homeid, data) ->
    if (homeid != window['curr_homeid'])
        console.log("Do not need " + homeid + " anymore. Current homeid = " + window['curr_homeid'])
        return
    console.log("Render " + homeid)
    clientId = data.client_id
    addClientId = clientId.length != 0
    $("#homeid").html(homeid)
    tableHead = $("#homedata-table thead")
    tableHead.html('')
    row = '<th>#</th>'
    if addClientId
        row += '<th>Client Id</th>'
    headers = getHeaders(data.data[0])
    for header in headers
        row += '<th>' + header.replace(/_/g, ' ') + '</th>'
    row = '<tr>' + row + '</tr>'
    tableHead.append(row)
    tableBody = $("#homedata-table tbody")
    console.log(data.data)
    tableBody.html('')
    i = 0
    while i < data.data.length
        item = data.data[i]
        row = '<td>' + i + '</td>'
        if addClientId
            row += '<td>' + clientId + '</td>'
        for header in headers
            row += '<td>' + item[header] + '</td>'
        row = '<tr>' + row + '</tr>'
        tableBody.append(row)
        i++
    $('#home-modal').foundation('reveal', 'open')


multiupload = (i, len) ->
    if i >= len
        alert 'Upload ' + window.success + ' files successfully, ' + window.fail + ' failed'
        $('.progress').fadeOut()
        load()
        return
    formData = new FormData()
    formData.append 'usage', document.getElementById('file').files[i]
    #formData.append 'format', 'gb'
    config_id_override = $("[name=config-id]").val()
    parser_override = $("[name=parser]").val()
    preprocess_override = $("[name=preprocess]").val()
    optional_parameters = $("[name=optional-parameters]").val()
    if config_id_override.length > 0
        formData.append 'config_id', config_id_override
    if parser_override.length > 0
        formData.append 'parser', parser_override
    if preprocess_override.length > 0
        formData.append 'preprocess', preprocess_override
    if optional_parameters.length > 0
        formData.append 'optional_parameters', optional_parameters
    $.ajax
        url: location.protocol + '//api.energyefficiency.me/v1/home'
        type: 'POST'
        beforeSend: (request) ->
            request.setRequestHeader 'Authorization', 'Bearer ' + window['apikey']
            value = i + 0.5
            total = len
            percent = value * 100 / total
            console.log percent
            $('.meter').width percent + '%'
            return
        success: ->
            window.success++
            return
        complete: ->
            value = i + 1
            total = len
            percent = value * 100 / total
            console.log percent
            $('.meter').width percent + '%'

            multiupload(i + 1, total)
            return
        error: (jqXHR) ->
            msg = JSON.parse(jqXHR.responseText).error.message
            window.fail++
            return
        data: formData
        contentType: false
        processData: false

uploadFile = ->
    window.success = 0
    window.fail = 0
    len = document.getElementById('file').files.length

    $('.meter').width '0%'
    $('.progress').show()

    multiupload(0, len)

    
    
    ###
    formData = new FormData($('#upload-form')[0])
    console.log formData
    $.ajax
        url: location.protocol + '//api.energyefficiency.me/v1/home'
        type: 'POST'
        xhr: ->
            myXhr = $.ajaxSettings.xhr()
            if myXhr.upload
                myXhr.upload.addEventListener 'progress', progressHandlingFunction, false
            myXhr
        beforeSend: (request) ->
            request.setRequestHeader 'Authorization', 'Bearer ' + window['apikey']
            $('.meter').width '0%'
            $('.progress').show()
            return
        success: ->
            alert 'Upload successful!'
            load()
            return
        complete: ->
            $('.progress').fadeOut()
            return
        error: (jqXHR) ->
            msg = JSON.parse(jqXHR.responseText).error.message
            alert 'Upload failed. \n' + msg
            return
        data: formData
        contentType: false
        processData: false
    ###
    return

progressHandlingFunction = (e) ->
    if e.lengthComputable
        value = e.loaded
        total = e.total
        percent = value * 100 / total
        console.log percent
        $('.meter').width percent + '%'
    return


$(document).ready ->
    window['cache'] = {}
    getApiKey()
    # Binding
    $('#reload-btn').click(load)
    $('button.file-upload').click (event) ->
        event.preventDefault()
        $('input.file-input').click()
        return
    $('input.file-input').click (event) ->
        event.stopPropagation()
        # Solve problem that change event will not triggered for same file
        this.value = null
        return
    #$('table').delegate 'a', 'click', ->
    $(document).on 'click', 'a.showhome', ->
        homeid = $(this).attr('homeid')
        loadHomeData(homeid)
    $(document).on 'click', 'a.downloadhome', ->
        homeid = $(this).attr('homeid')
        filename = $(this).attr('filename')
        fileprefix = filename.split('.')[0]
        downloadHomeData(homeid, fileprefix)
    $('input.file-input').change (event, numFiles, label) ->
        uploadFile()


