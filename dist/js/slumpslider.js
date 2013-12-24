/**
* slumpslider.js v0.0.1-a by @nurcahyo 
* Copyright 2013 Nurcahyo al hidayah <2light.hidayah@gmail.com>
* http://www.apache.org/licenses/LICENSE-2.0
*/
(function() {
  var Slumpslider;

  if (!jQuery) {
    throw new Error("Slumpslider requires jQuery");
  }

  "use strict";

  Slumpslider = (function() {
    Slumpslider.prototype.interval = void 0;

    Slumpslider.prototype.$context = null;

    Slumpslider.prototype.isLoaded = false;

    Slumpslider.prototype.$active = null;

    Slumpslider.prototype.isSliding = false;

    Slumpslider.prototype.$items = [];

    Slumpslider.prototype.$indicators = null;

    Slumpslider.prototype.position = 0;

    Slumpslider.prototype.options = {
      interval: 3000,
      pause: 'hover',
      autoRepeat: true
    };

    Slumpslider.prototype.isPlayed = false;

    Slumpslider.prototype.stop = function(e) {
      e || !(this.isPlayed = false);
      this.interval = clearInterval(this.interval);
      return this;
    };

    Slumpslider.prototype.play = function(e) {
      e || !this.isLoaded || (this.isPlayed = true);
      this.interval && clearInterval(this.interval);
      this.options.interval && this.isPlayed && (this.interval = setInterval($.proxy(this.next, this), this.options.interval));
      return this;
    };

    Slumpslider.prototype.next = function() {
      var context, position;
      context = this.$active.next();
      position = context.length ? this.position + 1 : 0;
      return this._to(position);
    };

    Slumpslider.prototype.prev = function() {
      var context, position;
      if (this.isSliding) {
        return;
      }
      context = this.$active.prev();
      position = context.length ? this.position - 1 : this.$items.length - 1;
      return this._to(position);
    };

    Slumpslider.prototype._slump = function(direction, context) {
      var e, isSlump;
      if (this.isSliding) {
        return;
      }
      this.isSliding = true;
      isSlump = this.interval;
      if (!context.hasClass('sliding')) {
        this.$active.removeClass('active sliding');
        this.$active = context;
      }
      isSlump && this.stop();
      e = $.Event('slump.slumps.obj', {
        target: this.$active[0]
      });
      context.addClass("active sliding");
      Slumpslider.animateIndicator(this.$indicators, this.position);
      this.isSliding = false;
      return isSlump && this.play();
    };

    Slumpslider.prototype._to = function(position) {
      var $this, activePosition;
      $this = this;
      activePosition = this.position;
      this.position = position;
      if (position > (this.$items.length - 1) || position < 0) {
        return;
      }
      if (this.isSliding) {
        return this.$context.one('slumps', function() {
          return $this._to(position);
        });
      }
      return this._slump((position < activePosition ? 'left' : 'right'), $(this.$items[position]));
    };

    Slumpslider.prototype.loading = function() {
      this.$indicators.hide();
      return this.stop(true);
    };

    Slumpslider.prototype.loaded = function() {
      this.isLoaded = 1;
      this.$indicators.show('fade');
      return this.play();
    };

    Slumpslider.prototype.__decorate__ = function() {
      var that, _tasks;
      that = this;
      that.loading(0);
      _tasks = [
        function(that) {
          var $context;
          $context = that.$context;
          if (!$context.hasClass('slumps')) {
            return $context.addClass('slumps');
          }
        }, function(that) {
          var isLoading;
          isLoading = 0;
          return that.$items.each(function() {
            var $items;
            $items = $(this);
            return $items.find('.slumps-object').each(function() {
              var $object, data, image;
              $object = $(this);
              data = $object.data();
              if (data.slumpsObject === 'background') {
                isLoading++;
                image = new Image;
                image.alt = data.alt ? data.alt : '';
                image.onload = function() {
                  isLoading--;
                  if (isLoading === 0) {
                    return that.loaded();
                  }
                };
                image.src = data.src ? data.src : '';
                image.classList.add('slumps-background');
                return $object.replaceWith(image);
              } else if (data.slumpsObject === 'layer') {

              }
            });
          });
        }
      ];
      return _tasks.forEach(function(callbacks) {
        return callbacks(that);
      });
    };

    function Slumpslider(context, options) {
      var $active, $this;
      $this = this;
      jQuery.extend(this.options, options);
      $this.$context = $(context);
      $this.$indicators = $this.$context.find('.slumps-indicators');
      $active = $this.$context.find('.item.active');
      if (!$active.length) {
        $active = $(context.getElementsByClassName('item'));
      }
      $this.$active = $active.addClass('sliding');
      $this.$items = $this.$active.parent().children('.item');
      $this.position = $this.$items.index($this.$active);
      $this.$context.data('slumps.obj', $this);
      $this.__decorate__();
      Slumpslider.registerEvents(context);
    }

    Slumpslider.registerEvents = function(context) {
      return jQuery(context).on('click.slumps.obj.data-api', '[data-slumps-for]', function(e) {
        var $target, $this, href, options, sliderIndex;
        e.preventDefault();
        $this = $(this);
        options = {};
        $target = $($this.attr("data-target") || (href = $this.attr("href")) && href.replace(/.*(?=#[^\s]+$)/, ""));
        sliderIndex = $this.attr('data-slumps-for');
        if (sliderIndex) {
          options.interval = false;
        }
        $target.slumpslider(options);
        return $target.data('slumps.obj')._to(parseInt(sliderIndex));
      });
    };

    Slumpslider.animateIndicator = function($indicators, position) {
      var actives, i;
      if ($indicators.length) {
        actives = $indicators[0].getElementsByClassName('active');
        i = 0;
        while (i < actives.length) {
          actives.item(i).classList.remove('active');
          ++i;
        }
      }
      return $indicators.find('[data-slumps-for="' + position + '"]').each(function() {
        return $(this).addClass('active');
      });
    };

    return Slumpslider;

  })();

  jQuery.fn.slumpslider = function(options) {
    var actionName;
    actionName = (typeof options === "string" ? options : false);
    if (actionName[0] === "_") {
      throw "Can't access private method";
    }
    options = (typeof options === "object" ? options : {});
    return this.each(function() {
      var $this, slider;
      $this = $(this);
      slider = $this.data('slumps.obj');
      if (!(slider instanceof Slumpslider)) {
        slider = new Slumpslider(this, options);
      } else if (options.interval) {
        jQuery.extend(slider.options, options);
      }
      if (actionName) {
        slider[actionName]();
      } else if (slider.options.interval) {
        slider.stop().play();
      }
    });
  };

  jQuery(function($) {
    return $('.slumps').slumpslider();
  });

}).call(this);
