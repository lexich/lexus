define ["jQuery","underscore","Backbone"],($, _, Backbone)->

  Preloader = do(
    __super__ = Backbone.View 
  )-> __super__.extend
        el:"[data-js-preloader]:first"
        render:->
          $original = @$el.find "[data-js-preloader-original]"
          $shadow = @$el.find "[data-js-preloader-shadow]"
          $shadow.css
            position:"absolute"
            top: $original.position().top
            left:$original.position().left

          return if $shadow.length <= 0 or $original.length <= 0
          $shadow.animate {
            left:"+=#{$original.width()}"
          }, {
            duration: 2000
            complete: =>
              $shadow.parent("[data-js-preloader]").fadeOut(400)
              @options?.next?()
          }
          __super__::render.apply this, arguments

  Preloader