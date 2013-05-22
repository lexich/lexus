require [
  "jQuery"
  "lib/jquery.scrollpage"
],($)->

  preloader = (next=->)->
    $original = $("[data-js-preloader-original]")
    $shadow = $("[data-js-preloader-shadow]")
    return if $shadow.length <= 0 or $original.length <= 0
    $shadow.animate {
      left:"+=#{$original.width()}"
    }, {
      duration: 4000
      complete: ->
        $shadow.parent("[data-js-preloader]").fadeOut(400)
        next()
    }

  $(document).ready ->
    $("[data-js-scrollmenu] a").scrollPage()
    preloader()
