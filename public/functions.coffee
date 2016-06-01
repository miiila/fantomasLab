#################
#OnLoad Handlers#
#################

(($) ->

) jQuery

loadingSequence = "<div class='terminalRow'>> ^1000 Starting CML connection </div> <div class='terminalRow'>> ^1000 Loading kernel </div> <div class='terminalRow'> > ^1000 Loading map</div>"

$( ->
  $('input').val('')
  $('.nonStartup').hide()

  $('#typed').typed(
    strings: [loadingSequence],
    typeSpeed: 50,
    showCursor: true
    callback: ->
      $('.typed-cursor').hide()
      $('.nonStartup').show()
      inputFocus()
  )

  $(document).click( ->
    inputFocus()
  )
  $(document).keydown((event) ->
    keyCode = event.keyCode
    switch
      when keyCode == 13
        processCommand($('#command'))
      when (keyCode in [9..36] or keyCode > 90) and keyCode != 32
        event.preventDefault();
        inputFocus();
  )
  inputFocus();
  window.cmlTasksTimes = new Array()
)

inputFocus = ->
  $('input').focus()

#################
#Submit handlers#
#################
processCommand = (data) ->
  command = data.val()
  if (command == '')
    $('#typed').append("<div class='terminalRow'> > missing command </div>")
  else
    if (command == 'cml shutdown')
      $('#command').val('')
      $('#typed').append("<div class='terminalRow'> Enter password: </div>")
      window.cmlShutdown = true
      $('#command').attr('type', 'password')
    else
      if(window.cmlShutdown == true and command != 'rvzbtlyocmshfquafadipxaacabaekdewaanjg')
        $('#typed').append("<div class='terminalRow'> WRONG CML PASSWORD </div>")
        window.cmlShutdown = false
        $('#command').attr('type', 'text')
        $('#command').val('')
      else
        if command == 'rvzbtlyocmshfquafadipxaacabaekdewaanjg' and window.cmlShutdown == true
          command = 'cml shutdown'
          document.getElementById("audioShutdown").play()
          $('#command').attr('type', 'text')
          window.cmlShutdown = false
        $('#typed').append("<div class='terminalRow'> > " + escapeString(command) + "</div>")
        $.ajax(
          type: 'GET',
          url: '/processCommand/' + command,
          beforeSend: ->
            $('#command').val('Processing...')
        ).done(processResult)

processResult = (result) ->
  setTimeout(->
    switch result.type
      when 'open'
        if result.success
          flashSign = flash($('#granted'))
          document.getElementById("audioGranted").play()
          openLocation(result.location)
          if result.finished?
            $('#areal').css('background-image', 'url(../images/areal_exit.png)')
        else
          flashSign = flash($('#denied'))
          document.getElementById("audioDenied").play()
        setTimeout(->
            finishFlash(flashSign)
          ,4000)
      when 'system'
        if result.success && result.command == 'shutdown'
          openLocation(location) for location in result.locations
          $('.cmlState').text('STOPPED')
          $('.cmlState').addClass('red')
          $('#cmlTasks').text('')
        else
          $('#typed').append("<div class='terminalRow'> > unknown command</div>")
      when 'view'
        if result.success
          $('#typed').append("<div class='terminalRow'> > " + escapeString(result.info) + "</div>")
        else
          $('#typed').append("<div class='terminalRow'> > unknown task</div>")
      else
        $('#typed').append("<div class='terminalRow'> > unknown command</div>")
    #Clear input form
    $('#command').val('')
  ,2000)


openLocation = (locationId) ->
  if (locationId.slice(-1) == '4')
    $('#'+locationId).html(' SECTOR CLEAR')
  else
    $('#'+locationId).removeClass('closed')
    $('#'+locationId).addClass('opened')

startCmlTask = (cmlStartedTask) ->
  return null for cmlTask in window.cmlTasksTimes when cmlTask.id == cmlStartedTask.id
  window.cmlTasksTimes.push({"id":cmlStartedTask.id,"miliseconds":cmlStartedTask.miliseconds})
  innerHtml = "<div class='quest_green'><span>"+cmlStartedTask.name+"<br /> ("+cmlStartedTask.id+")</span><span id=\""+cmlStartedTask.id+"\" class='floatRight'>"+cmlStartedTask.time+"</span></div>"
  $('#cmlTasks').append(innerHtml)

finishCmlTask = (cmlFinishedTask) ->
  $('#'+cmlFinishedTask.id).parent().remove()
  cmlTask.finished = true for cmlTask in window.cmlTasksTimes when cmlTask.id == cmlFinishedTask.id

################
#Util functions#
################
formatTime = (number,places) ->
  if number < (10 ** (places-1))
    unless number.length == places
      number = '0' + number
  return number

formatTwoDigitTime = (number) ->
  return formatTime(number,2)

parseTime = (time) ->
  newTime = new Date(time);
  output = formatTwoDigitTime(newTime.getHours()) + ':' + formatTwoDigitTime(newTime.getMinutes()) + ':' + formatTwoDigitTime(newTime.getSeconds());
  return output;

flash = (objectToFlash) ->
  objectToFlash.toggleClass('hidden')
  setInterval(->
    objectToFlash.toggleClass('hidden')
  ,700)
  
# http://shebang.brandonmintern.com/foolproof-html-escaping-in-javascript/
escapeString = (str) ->
  div = document.createElement('div');
  div.appendChild(document.createTextNode(str));
  return div.innerHTML;
  
finishFlash = (intervalVar) ->
  clearInterval(intervalVar)
  $('.sign').addClass('hidden')

countCmlTime = ->
  window.cmlTasksTimes =
    for taskTime in window.cmlTasksTimes when taskTime.finished? != true
      newTime = taskTime.miliseconds - (100+window.balance)
      taskTimeObject = new Date(newTime)
      formattedTimeString = formatTwoDigitTime(taskTimeObject.getMinutes())+":"+formatTwoDigitTime(taskTimeObject.getSeconds())
      if formattedTimeString == '03:00'
        $('#'+taskTime.id).parent().removeClass('quest_green')
        $('#'+taskTime.id).parent().addClass('quest_red')
      $('#'+taskTime.id).text(formattedTimeString)
      if formattedTimeString == '00:00'
        flash($('#'+taskTime.id).parent())
        setTimeout(->
          reloadPage()
        ,5000)
        break
      {"miliseconds":newTime,"id":taskTime.id}

reloadPage = ->
  socket.emit('cmlRestarted')
  document.cookie="timeDiff="+(timeDiff);
  document.getElementById("audioRestart").play()
  setTimeout(()->
    window.location.reload()
  ,2000)
