require [
  "jQuery"  
  "underscore"
  "lib/Car"
  "lib/Preloader"
  "lib/Scroller"
],($, _, Car, Preloader, Scroller)->


  $(document).ready ->
    $("[data-js-audio-change]").click (e)->
      e.preventDefault()
      $item = $(e.target)

      src = $item.attr("src")
      change = $item.data("js-audio-change")
      $item.attr("src", change)
      $item.data("js-audio-change", src)

    preloader = new Preloader    	
    preloader.render()

    $car = $("[data-js-car]:first")
    data = $car.data("js-car") ? {}
    car = new Car
      el:$car
      movement:data.movement
      duration:data.duration
    #car.render()
    #scroller = new Scroller()


