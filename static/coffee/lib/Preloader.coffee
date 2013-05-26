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
            width: $original.width()
            height: $original.height()            

          return if $shadow.length <= 0 or $original.length <= 0          
          left = "+=#{$original.width()}"
          duration = @options.duration ? 2000          
          $shadow.animate { left }, {
            duration            
            complete: =>
              $shadow.parent("[data-js-preloader]").fadeOut(@options.fadeout ? 400)
              @options?.next?()
          }
          __super__::render.apply this, arguments

  Preloader