###
Tiny Cookie manipulation library
aimed to salvage info from malformed cookies
###
class Biskoto
  encode = encodeURIComponent
  decode = decodeURIComponent

  ###
  Creates the cookie string
  @param [String] name  The name of the cookie
  @param [String] value The value of the cookie
  @param [Object] options Cookie attribute values
  @see https://developer.mozilla.org/en-US/docs/Web/API/document.cookie for
  a list of available attributes
  @return [String] The new value to be set to the cookie
  ###
  @_createCookieString: (name, value, options = {}) ->
    if $.type(value) in ['object', 'array']
      json_value = JSON.stringify(value)
    else
      json_value = value

    "#{encode(name)}=#{encode(json_value)}#{@_normalizeAndSerializeOptions(options)}"

  ###
  Converts the provided date to the valid format
  @param [Number|Date] date
  @return [String] A UTC string
  ###
  @_normalizeDate: (date) ->
    expires_type = $.type(date)
    if expires_type is 'number'
      new Date((new Date).getTime() + date * 1000).toUTCString()
    else if expires_type is 'date'
      date.toUTCString()
    else
      ''

  ###
  Performs various operations to ensure the validity of the cookie string
  @param [Object] options Cookie attribute values
  @return [String] The normalized options
  ###
  @_normalizeAndSerializeOptions: (options = {}) ->
    cookie_str = ''

    for key, value of options
      if key is 'expires'
        cookie_str += "; expires=#{@_normalizeDate(options.expires)}"
      else if key is 'secure'
        cookie_str += "; secure"
      else
        cookie_str += "; #{key}=#{value}"

    cookie_str += "; path=#{if options.path? then options.path else '/'}"

  ###
  Extracts the key and value from a string that contains them
  @param [String] cookie_part The key-value pair to be processed
  @param [Function] decoder The decoding function to be used
  @return [Array] The key-value pair
  ###
  @_getKeyValuePair = (cookie_part, decoder) ->
    try
      cookie_name  = decoder(cookie_part.match(/([^=]+)=/i)[1])
      cookie_value = decoder(cookie_part[cookie_name.length + 1...])
    catch e
      # nop
    [cookie_name, cookie_value]

  ###
  Gets a cookie value by name
  @param [String] name The name of the cookie
  @param [Object] options Settings to determine how the cookie
  string is processed. Currenlty only decode, which when set to false
  does not url decode the cookie value.
  @return [String|Object|Array|Number|null] The parsed json value of the cookie
  if decode is true else the string value of the cookie or null if it is not found
  @todo: cache the parsed object
  ###
  @get: (name, options = { decode: true }) ->
    return null if $.type(document.cookie) isnt 'string' or !navigator.cookieEnabled

    cookies = {}
    decoder = if options.decode is true then decode else (s) -> s

    for cookie_part in document.cookie.split(/;\s/g)
      [cookie_name, cookie_value] = @_getKeyValuePair(cookie_part, decoder)
      continue if !cookie_name? or cookie_name is ''
      cookies[cookie_name] = cookie_value

    if options.decode is true
      try
        cookies[name] = $.parseJSON(cookies[name])
      catch Error
        cookies[name]

    cookies[name] || null

  ###
  Sets the value of a cookie
  @param [String] name The name of the cookie to be set
  @param [String] value The value of the cookie
  @param [Object] options Cookie attribute values
  ###
  @set: (name, value, options) ->
    return if name is ''
    document.cookie = @_createCookieString.apply(@, arguments)

  ###
  Expires a cookie
  @param [String] The name of the cookie to expire
  ###
  @expire: (name, options= {}) ->
    options.expires = -1
    document.cookie = @_createCookieString(name, 'null', options)


# Make it an AMD module if a loader is present else global
if typeof define is 'function' && define.amd
  define -> Biskoto
else
  window.Biskoto = Biskoto
