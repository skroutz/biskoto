describe 'Biskoto', ->
  @timeout(0) # Disable the spec's timeout

  before (done) ->
    require ['biskoto'], (Biskoto) =>
      @Biskoto = Biskoto
      done()

  it 'is a class', ->
    @Biskoto.should.be.a 'function'

  describe '.get', ->
    context 'when the cookie is well formed and non empty', ->
      beforeEach ->
        @expected_value = encodeURIComponent('i can haz cookie')
        document.cookie = "foo=#{@expected_value}"

      afterEach ->
        document.cookie = 'foo=null; expires=Thu, 01 Jan 1970 00:00:01 GMT'
        delete @expected_value

      context 'and option decode is set to false', ->
        it 'parses the key-value without decoding it', ->
          @Biskoto.get('foo', { decode: false }).should.equal @expected_value

      context 'and decode option is not set', ->
        it 'parses the key-value pair decoded', ->
          @Biskoto.get('foo')
            .should
            .equal decodeURIComponent(@expected_value)

      context 'and option decode is set to true', ->
        it 'parses the key-value decoded', ->
          @Biskoto.get('foo', { decode: true })
            .should
            .equal decodeURIComponent(@expected_value)

        context 'and the content is a json object', ->
          it 'parses and returns the object', ->
            numbers = { one: 1, two: 2 }
            @expected_value = encodeURIComponent(JSON.stringify(numbers))
            document.cookie = "foo=#{@expected_value}"
            expect(@Biskoto.get('foo')).to.eql numbers

    context 'when the cookie is partly undecodable', ->
      beforeEach ->
        @expected_value = encodeURIComponent('i can haz cookie')
        document.cookie = "foo=%%%32342234!"  # malformed
        document.cookie = "bar=#{@expected_value}"

      afterEach ->
        document.cookie = 'foo=null; expires=Thu, 01 Jan 1970 00:00:01 GMT'
        document.cookie = 'bar=null; expires=Thu, 01 Jan 1970 00:00:01 GMT'
        delete @expected_value

      it 'manages to salvage decodable values', ->
        @Biskoto.get('bar')
          .should
          .equal decodeURIComponent(@expected_value)

    context 'when there is no such cookie', ->
      it 'returns null', ->
        (@Biskoto.get('i_do_not_exist') is null).should.be.true

  describe '.set', ->
    afterEach ->
      document.cookie = 'foo=null; expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/'

    context 'when name parameter is a non-empty string', ->
      it 'calls _createCookieString', ->
        _createCookieString_spy = sinon.spy @Biskoto, '_createCookieString'
        @Biskoto.set('foo', 'lala')
        _createCookieString_spy.called.should.be.true
        _createCookieString_spy.restore()

    context 'when the value parameter is an non empty array', ->
      it 'calls _createCookieString', ->
        _createCookieString_spy = sinon.spy @Biskoto, '_createCookieString'
        @Biskoto.set('foo', [1,2,3])
        _createCookieString_spy.called.should.be.true
        _createCookieString_spy.restore()

      it "stores the json representation of the array", ->
        @Biskoto.set('foo', [1,2,3])
        @Biskoto.get('foo').should.deep.equal([1,2,3])
        @Biskoto.get('foo', { decode: false }).should
          .equal(encodeURIComponent(JSON.stringify([1,2,3])))

  describe '.expire', ->
    context 'when the cookie to be deleted is set at the default path', ->
      beforeEach ->
        document.cookie = 'foo=lala; path=/'

      afterEach ->
        document.cookie = 'foo=null; expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/'

      it 'gets expired successfully', ->
        @Biskoto.expire('foo')
        (@Biskoto.get('foo') is null).should.be.true

  describe 'Private functions', ->
    describe '._normalizeAndSerializeOptions', ->
      context 'when expires key is set', ->
        beforeEach ->
          @toUTCString_spy = sinon.spy(Date.prototype, 'toUTCString')

        afterEach -> @toUTCString_spy.restore()

        context 'and is a Number', ->
          before -> @options = { expires: 60 * 60 }
          after -> delete @options

          it 'performs formatting to UTC String', ->
            @Biskoto._normalizeAndSerializeOptions(@options)
            @toUTCString_spy.called.should.be.true

        context 'and is a Date', ->
          before -> @options = { expires: new Date }
          after -> delete @options

          it 'performs formatting to UTC String', ->
            @Biskoto._normalizeAndSerializeOptions(@options)
            @toUTCString_spy.called.should.be.true

      context 'when expires key is not set', ->
        it 'does not set an expiration (session cookie)', ->
          cookie = @Biskoto._normalizeAndSerializeOptions()
          /expires=/.test(cookie).should.be.false

    describe '.createCookieString', ->
      it 'returns a String', ->
        @Biskoto._createCookieString('foo', 'bar').should.be.a.string

      it 'calls _normalizeAndSerializeOptions', ->
        _normalizeAndSerializeOptions_spy = sinon.spy(@Biskoto, '_normalizeAndSerializeOptions')
        @Biskoto._createCookieString('foo', 'bar').should.be.a.string
        _normalizeAndSerializeOptions_spy.called.should.be.true
        _normalizeAndSerializeOptions_spy.restore()

      it 'contains the given pair', ->
        cookie = @Biskoto._createCookieString('foo', 'bar')
        expect(/foo=bar/.test(cookie)).to.equal(true)
