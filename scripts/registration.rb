require 'logger'
require 'nokogiri'
require 'httparty'

class Object
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end

  def present?
    !blank?
  end

  def presence
    self if present?
  end
end

class YiiChina
  include HTTParty
  base_uri 'www.yiichina.com'

  def initialize(username:, password:)
    @csrf_token = nil
    @identity_cookie = nil
    @username, @password = username, password
    @user_agent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:39.0) Gecko/20100101 Firefox/39.0'.freeze

    raise ArgumentError.new('User identity isn\'t correct') if @username.blank? || @password.blank?
  end

  def login
    raise 'Already logged in' unless @identity_cookie.nil?

    login_get_resp = self.class.get('/login', headers: { 'User-Agent' => @user_agent })
    login_form_html = Nokogiri::HTML(login_get_resp.body)
    csrf_meta_param_tag = login_form_html.at_css('meta[name="csrf-param"]').freeze
    csrf_meta_token_tag = login_form_html.at_css('meta[name="csrf-token"]').freeze
    login_get_req_cookie = parse_set_cookies(login_get_resp.headers['Set-Cookie'])

    login_post_resp = self.class.post('/login', {
      follow_redirects: false,
      headers: {
        'User-Agent' => @user_agent,
        'Cookie' => login_get_req_cookie.to_cookie_string
      },
      body: {
        'LoginForm' => {
          'rememberMe' => '0',
          'username' => @username,
          'password' => @password,
        },
        csrf_meta_param_tag['content'] => csrf_meta_token_tag['content'],
      },
    })

    case login_post_resp.code
    when 302
      @csrf_token = csrf_meta_token_tag['content']
      @identity_cookie = parse_set_cookies(login_post_resp.headers['Set-Cookie'])
      return true
    when 200
      raise 'Username or Password might not match'
    else
      raise 'Unknown login exception'
    end
  end

  def registration
    raise 'Not loggin yet' if @identity_cookie.nil?

    reg_resp = self.class.get('/registration', {
      follow_redirects: false,
      headers: {
        'User-Agent' => @user_agent,
        'X-CSRF-Token' => @csrf_token,
        'X-Requested-With' => 'XMLHttpRequest',
        'Cookie' => @identity_cookie.to_cookie_string,
        'Accept' => 'application/json, text/javascript, */*; q=0.01',
      },
    })

    case reg_resp.code
    when 200
      logger.info 'Registration succeed today'
    when 500
      logger.info 'Registration failed, might already done'
    end
  end

  private

  def logger
    @logger ||= ::Logger.new(STDOUT)
  end

  def parse_set_cookies(set_cookie)
    cookie_hash = CookieHash.new
    set_cookie.split(', ').each { |c| cookie_hash.add_cookies(c) }
    cookie_hash
  end
end
