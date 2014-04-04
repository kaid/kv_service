jQuery ->
  $login = jQuery("form.login")

  $login.on "submit", (e)->
    e.preventDefault()

    deferred = jQuery.ajax
      type : $login.attr("method")
      url  : $login.attr("action")
      data : $login.serialize()

    deferred.done ->
      $login.addClass("done")
      window.location = "/"

    deferred.fail ->
      $login.addClass("fail")
