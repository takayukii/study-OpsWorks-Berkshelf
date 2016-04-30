require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'kconv'

url = 'https://ja.wikipedia.org/wiki/%E9%81%93%E3%81%AE%E9%A7%85%E4%B8%80%E8%A6%A7_%E9%96%A2%E6%9D%B1%E5%9C%B0%E6%96%B9'

options = {
    :user_agent => 'AnemoneCrawler/0.0.1',
    :delay => 1,
    :depth_limit => 1,
}

Anemone.crawl(url, options) do |anemone|

  # クロールする対象のリンクを絞り込む
  anemone.focus_crawl do |page|

    doc = Nokogiri::HTML.parse(page.body.toutf8)
    nodes = doc.xpath('//*[@id="mw-content-text"]/table/tr/td[1]/a')

    nodes = nodes.select do |node|
      is_valid_url = node.attribute('href').to_s.match(/\/wiki\/.*/)
      is_valid_title = node.attribute('title').to_s.match(/道の駅.*/)
      is_valid_url && is_valid_title
    end

    links = nodes.map do |node|
      # puts node.attribute('title').to_s + ': ' + node.attribute('href').to_s
      URI.parse(page.url.scheme + '://' + page.url.host + node.attribute('href'))
    end
    links

  end

  # 解析処理を行う
  anemone.on_every_page do |page|

    doc = Nokogiri::HTML.parse(page.body.toutf8)

    if ! doc.at('title').inner_html.to_s.match(/道の駅一覧/) then
      puts doc.at('title').inner_html.to_s
      puts page.url
    end

  end

end