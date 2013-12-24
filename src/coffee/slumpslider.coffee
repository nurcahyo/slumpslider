throw new Error "Slumpslider requires jQuery" if !jQuery
`"use strict"`
class Slumpslider 

  interval: undefined
  $context:null
  isLoaded: false
  $active: null
  isSliding: false
  $items: []
  $indicators: null
  position: 0

# Plugin default options
  options:
    interval: 3000
    pause: 'hover'
    autoRepeat: true
    
  # this slider is played
  isPlayed: false

  #stop slider
  stop: (e)->
    e or not @isPlayed = false
    @interval= clearInterval(@interval)
    return @
  
  #play slider
  play: (e)->
    e or not @isLoaded or (@isPlayed = true)
    @interval and clearInterval(@interval)
    @options.interval and 
    @isPlayed and 
    (@interval= setInterval($.proxy(@next, this), @options.interval))
    this
  
  #to next slide
  next: ()->
    context= @$active.next()
    position= if context.length then @position+1 else 0
    @_to(position)
    
  #to previous slide
  prev: ()->
    return if @isSliding
    context= @$active.prev()
    position= if context.length then @position-1 else @$items.length - 1
    @_to(position)  
    
  
  _slump: (direction,context)->
    return if @isSliding
    @isSliding= true
    isSlump = @interval
    
    unless context.hasClass('sliding')
      @$active.removeClass('active sliding')
      @$active=context
      
    isSlump and @stop()
    
    e = $.Event('slump.slumps.obj',
      target: @$active[0]
    )
    
    context.addClass("active sliding")
    Slumpslider.animateIndicator(@$indicators,@position)
    
    @isSliding= false
    isSlump and @play()
    
  _to: (position)->
    $this = @
    activePosition=@position
    @position=position
    if position > (@$items.length - 1) or position < 0 
      return
    if @isSliding 
      return @$context.one('slumps',()->
        $this._to(position)
      )
    return @_slump((if position < activePosition then 'left' else 'right'), $(@$items[position]))
  
  loading: ()->
    @$indicators.hide()
    @stop(true)
  
  loaded: ()->
    @isLoaded=1
    @$indicators.show('fade')
    @play()
    
  __decorate__:()->
    that=@
    that.loading(0)
    _tasks= [
      ##decorate slumps container
      (that)->
        $context=that.$context
        unless $context.hasClass('slumps')
          $context.addClass('slumps')
      ##decorate items inner html
      (that)->
        isLoading= 0
        that.$items.each ()->
          $items=$(this)
          $items.find('.slumps-object').each ()->
            $object=$(this)
            data=$object.data()
            if data.slumpsObject is 'background'
              isLoading++
              image= new Image
              image.alt= if data.alt then data.alt else ''
              image.onload=()->
                isLoading--
                if isLoading is 0
                  that.loaded()
              image.src= if data.src then data.src else ''
              image.classList.add('slumps-background')
              $object.replaceWith(image)
            else if data.slumpsObject is 'layer'
              return
           
    ]
    _tasks.forEach (callbacks)-> callbacks(that)  

    
  # Constructor
  constructor:(context,options)->
    $this=@
    jQuery.extend @options, options
    $this.$context = $(context)
    $this.$indicators= $this.$context.find('.slumps-indicators')
    $active= $this.$context.find('.item.active') 
    unless $active.length
      $active=$(context.getElementsByClassName('item'))
    $this.$active= $active.addClass('sliding')
    $this.$items= $this.$active.parent().children('.item')
    $this.position=$this.$items.index($this.$active)
    $this.$context.data('slumps.obj',$this)
    $this.__decorate__()
    Slumpslider.registerEvents(context)
    

  @registerEvents: (context)->
    jQuery(context).on 'click.slumps.obj.data-api','[data-slumps-for]',(e)->
      e.preventDefault()
      $this=$(this)
      options={}
      $target=$ $this.attr("data-target") or (href = $this.attr("href")) and href.replace(/.*(?=#[^\s]+$)/, "")
      sliderIndex=$this.attr('data-slumps-for')
      options.interval= false if sliderIndex
      $target.slumpslider(options)
      $target.data('slumps.obj')._to(parseInt(sliderIndex))
      
  @animateIndicator: ($indicators,position)->
    if $indicators.length
      actives=$indicators[0].getElementsByClassName('active')
      i=0
      while i < actives.length
        actives.item(i).classList.remove('active')
        ++i
    $indicators.find('[data-slumps-for="'+position+'"]').each ()->
      $(this).addClass('active')
      
jQuery.fn.slumpslider= (options)->
  actionName= (if typeof options is "string" then options else false)
  throw("Can't access private method") if actionName[0] is "_"
  options=(if typeof options is "object" then options else {})
  this.each ()->
    $this=$(this)
    slider=$this.data('slumps.obj')
    unless slider instanceof Slumpslider
      slider= new Slumpslider(@,options)
    else jQuery.extend slider.options,options
    if actionName
      slider[actionName]()
    else if slider.options.interval
      slider.stop().play()
    return
    
#todo: clear this test initialize
jQuery ($)->
  $('.slumps').slumpslider()
