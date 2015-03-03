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
  $(document).keypress((event) ->
    switch event.keyCode
      when 9
        event.preventDefault();
        inputFocus();
      when 13
        processCommand($('#command'))
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
          openLocation(result.location)
        else
          flashSign = flash($('#denied'))
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
          $('#command').val('unknown command')
      #Clear input form
    $('#command').val('')
  ,2000)

openLocation = (locationId) ->
  $('#'+locationId).removeClass('closed')
  $('#'+locationId).addClass('opened')

startCmlTask = (cmlStartedTask) ->
  return null for cmlTask in window.cmlTasksTimes when cmlTask.id == cmlStartedTask.id
  window.cmlTasksTimes.push({"id":cmlStartedTask.id,"miliseconds":cmlStartedTask.miliseconds})
  innerHtml = "<div class='quest_green'><span>"+cmlStartedTask.name+"</span><span id=\""+cmlStartedTask.id+"\" class='floatRight'>"+cmlStartedTask.time+"</span></div>"
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
          window.location.reload()
        ,5000)
        break
      {"miliseconds":newTime,"id":taskTime.id}