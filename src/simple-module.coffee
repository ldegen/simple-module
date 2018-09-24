class SimpleModule

  # Add properties to {SimpleModule} class.
  #
  # @param [Object] obj The properties of {obj} will be copied to {SimpleModule}
  #                     except a property named `extended`, which is a function
  #                     that will be called after copy operation.
  @extend: (obj) ->
    unless obj and typeof obj == 'object'
      throw new Error('SimpleModule.extend: param should be an object')

    for key, val of obj when key not in ['included', 'extended']
      @[key] = val

    obj.extended?.call(@)

  # Add properties to instance of {SimpleModule} class.
  #
  # @param [Hash] obj The properties of {obj} will be copied to prototype of
  #                   {SimpleModule}, except a property named `included`, which
  #                   is a function that will be called after copy operation.
  @include: (obj) ->
    unless obj and typeof obj == 'object'
      throw new Error('SimpleModule.include: param should be an object')

    for key, val of obj when key not in ['included', 'extended']
      @::[key] = val

    obj.included?.call(@)

  #_connectedClasses: []

  @connect: (cls) ->
    unless cls and typeof cls == 'function'
      throw new Error('SimpleModule.connect: param should be a function')

    unless cls.pluginName
      throw new Error('SimpleModule.connect: cannot connect plugin without pluginName')

    cls::_connected = true
    @_connectedClasses = [] unless @_connectedClasses
    @_connectedClasses.push(cls)
    @[cls.pluginName] = cls

  opts: {}

  # Create a new instance of {SimpleModule}
  #
  # @param [Hash] opts The options for initialization.
  #
  # @return The new instance.
  constructor: (opts) ->
    @opts = $.extend {}, @opts, opts

    @constructor._connectedClasses ||= []
    # Create singleton instances of connected classes
    instances = for cls in @constructor._connectedClasses
      # lowercase first letter of class name
      name = cls.pluginName.charAt(0).toLowerCase() + cls.pluginName.slice(1)
      # store reference to parent module
      cls::_module = @ if cls::_connected
      # add newly created/singleton instance to “this” module
      @[name] = new cls()

    # Are we a mounted submodule?
    if @_connected
      # Yes; just merge the parent module’s options into ours
      @opts = $.extend {}, @opts, @_module.opts
    else
      # No; call our own initialisator and all mounted submodules’
      @_init()
      instance._init?() for instance in instances

    @trigger 'initialized'

  _init: ->

  on: (args...) ->
    $(@).on args...
    @

  off: (args...) ->
    $(@).off args...
    @

  trigger: (args...) ->
    $(@).trigger(args...)
    @

  triggerHandler: (args...) ->
    $(@).triggerHandler(args...)

  one: (args...) ->
    $(@).one args...
    @

  #COPIED:BEG{
  _t: (args...) ->
    @constructor._t args...

  @_t: (key, args...) ->
    result = @i18n[@locale]?[key] || ''

    return result unless args.length > 0

    result = result.replace /([^%]|^)%(?:(\d+)\$)?s/g, (p0, p, position) ->
      if position
        p + args[parseInt(position) - 1]
      else
        p + args.shift()

    result.replace /%%s/g, '%s'

  @i18n:
    'en': {}
    'zh-CN': {}

  @locale: 'zh-CN'
  #COPIED:END}

module.exports = SimpleModule
