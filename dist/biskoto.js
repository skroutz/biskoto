
/*
Tiny Cookie manipulation library
aimed to salvage info from malformed cookies
 */
var Biskoto;

Biskoto = (function() {
  var decode, encode;

  function Biskoto() {}

  encode = encodeURIComponent;

  decode = decodeURIComponent;


  /*
  Creates the cookie string
  @param [String] name  The name of the cookie
  @param [String] value The value of the cookie
  @param [Object] options Cookie attribute values
  @see https://developer.mozilla.org/en-US/docs/Web/API/document.cookie for
  a list of available attributes
  @return [String] The new value to be set to the cookie
   */

  Biskoto._createCookieString = function(name, value, options) {
    var json_value, _ref;
    if (options == null) {
      options = {};
    }
    if ((_ref = $.type(value)) === 'object' || _ref === 'array') {
      json_value = JSON.stringify(value);
    } else {
      json_value = value;
    }
    return "" + (encode(name)) + "=" + (encode(json_value)) + (this._normalizeAndSerializeOptions(options));
  };


  /*
  Converts the provided date to the valid format
  @param [Number|Date] date
  @return [String] A UTC string
   */

  Biskoto._normalizeDate = function(date) {
    var expires_type;
    expires_type = $.type(date);
    if (expires_type === 'number') {
      return new Date((new Date).getTime() + date * 1000).toUTCString();
    } else if (expires_type === 'date') {
      return date.toUTCString();
    } else {
      return '';
    }
  };


  /*
  Performs various operations to ensure the validity of the cookie string
  @param [Object] options Cookie attribute values
  @return [String] The normalized options
   */

  Biskoto._normalizeAndSerializeOptions = function(options) {
    var cookie_str, key, value;
    if (options == null) {
      options = {};
    }
    cookie_str = '';
    for (key in options) {
      value = options[key];
      if (key === 'expires') {
        cookie_str += "; expires=" + (this._normalizeDate(options.expires));
      } else if (key === 'secure') {
        cookie_str += "; secure";
      } else {
        cookie_str += "; " + key + "=" + value;
      }
    }
    return cookie_str += "; path=" + (options.path != null ? options.path : '/');
  };


  /*
  Extracts the key and value from a string that contains them
  @param [String] cookie_part The key-value pair to be processed
  @param [Function] decoder The decoding function to be used
  @return [Array] The key-value pair
   */

  Biskoto._getKeyValuePair = function(cookie_part, decoder) {
    var cookie_name, cookie_value, e;
    try {
      cookie_name = decoder(cookie_part.match(/([^=]+)=/i)[1]);
      cookie_value = decoder(cookie_part.slice(cookie_name.length + 1));
    } catch (_error) {
      e = _error;
    }
    return [cookie_name, cookie_value];
  };


  /*
  Gets a cookie value by name
  @param [String] name The name of the cookie
  @param [Object] options Settings to determine how the cookie
  string is processed. Currently only decode, which when set to false
  does not url decode the cookie value.
  @return [String|Object|Array|Number|null] The parsed json value of the cookie
  if decode is true else the string value of the cookie or null if it is not found
  @todo: cache the parsed object
   */

  Biskoto.get = function(name, options) {
    var Error, cookie_name, cookie_part, cookie_value, cookies, decoder, _i, _len, _ref, _ref1;
    if (options == null) {
      options = {
        decode: true
      };
    }
    if ($.type(document.cookie) !== 'string' || !navigator.cookieEnabled) {
      return null;
    }
    cookies = {};
    decoder = options.decode === true ? decode : function(s) {
      return s;
    };
    _ref = document.cookie.split(/;\s/g);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      cookie_part = _ref[_i];
      _ref1 = this._getKeyValuePair(cookie_part, decoder), cookie_name = _ref1[0], cookie_value = _ref1[1];
      if ((cookie_name == null) || cookie_name === '') {
        continue;
      }
      cookies[cookie_name] = cookie_value;
    }
    if (options.decode === true) {
      try {
        cookies[name] = $.parseJSON(cookies[name]);
      } catch (_error) {
        Error = _error;
        cookies[name];
      }
    }
    return cookies[name] || null;
  };


  /*
  Sets the value of a cookie
  @param [String] name The name of the cookie to be set
  @param [String] value The value of the cookie
  @param [Object] options Cookie attribute values
   */

  Biskoto.set = function(name, value, options) {
    if (name === '') {
      return;
    }
    return document.cookie = this._createCookieString.apply(this, arguments);
  };


  /*
  Expires a cookie
  @param [String] The name of the cookie to expire
   */

  Biskoto.expire = function(name, options) {
    if (options == null) {
      options = {};
    }
    options.expires = -1;
    return document.cookie = this._createCookieString(name, 'null', options);
  };

  return Biskoto;

})();

if (typeof define === 'function' && define.amd) {
  define(function() {
    return Biskoto;
  });
} else if (typeof window === 'object') {
  window.Biskoto = Biskoto;
}
