require 'mechanize'
require 'nokogiri'

class Quiz
  def initialize
    @table = table
  end

  def run
    result_hash
  end

  private

  def table
    Nokogiri::HTML.parse(main_page.content).css('table').first
  end

  def main_page
    mechanize = Mechanize.new
    mechanize.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    mechanize.get('https://staqresults.staq.com') do |page|
      main_page = page.form_with(action: '/sessions') do |f|
        f.email    = 'test@example.com'
        f.password = 'secret'
      end.click_button
      return main_page
    end
  end

  def result_hash
    result = {}
    table_data.each_slice(6) { |slice| result[slice.shift] = table_headers.zip(slice).to_h }
    result
  end

  def table_data
    @table.css('td').map(&:text)
  end

  def table_headers
    @headers ||= @table.css('th').map { |header| header.text.downcase.to_sym }.drop(1)
  end
end
