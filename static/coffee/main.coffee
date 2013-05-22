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
      duration: 2000
      complete: ->
        $shadow.parent("[data-js-preloader]").fadeOut(400)
        next()
    }

  $(document).ready ->
    $("[data-js-scrollmenu] a").scrollPage()
    $("[data-js-audio-change]").click (e)->
      e.preventDefault()
      $item = $(e.target)
      $img = $item.find("img:first")
      src = $img.attr("src")
      change = $item.data("js-audio-change")
      $img.attr("src", change)
      $item.data("js-audio-change", src)

    preloader()

