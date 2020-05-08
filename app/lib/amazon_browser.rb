class AmazonBrowser
  LOGIN_URL = 'https://www.amazon.co.jp/ap/signin?openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fwww.amazon.co.jp%2Fgp%2Fyourstore%2Fhome%3Fie%3DUTF8%26ref_%3Dnav_newcust&prevRID=GGWVQJPSBNPHF9V4557G&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.assoc_handle=jpflex&openid.mode=checkid_setup&openid.ns.pape=http%3A%2F%2Fspecs.openid.net%2Fextensions%2Fpape%2F1.0&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&pageId=jpflex&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0'
  def self.login
    browser = Watir::Browser.new :chrome, switches: ['--kiosk-printing']
    browser.goto(LOGIN_URL)
    browser.text_field(id: 'ap_email').set(ENV['EMAIL'])
    browser.element(id: "continue").click
    browser.wait

    browser.text_field(id: 'ap_password').set(ENV['PASSWORD'])

    browser.element(id: "signInSubmit").click
    browser.wait
    browser
  end

  def self.goto_history(browser, year)
    history_url = "https://www.amazon.co.jp/gp/your-account/order-history?opt=ab&digitalOrders=1&unifiedOrders=1&returnTo=&__mk_ja_JP=%E3%82%AB%E3%82%BF%E3%82%AB%E3%83%8A&orderFilter=year-#{year}"
    browser.goto(history_url)
    browser.wait
  end

  def self.scrape_history(browser, array = [])

    page_item_count = browser.divs(class: "a-box-group").count
    for idx in 0..(page_item_count - 1) do
      browser.div(class: "a-box-group", index: idx).scroll.to
      name = browser.div(class: "a-box-group", index: idx).element(class: "a-box", index: 1).element(class: "a-link-normal", index: 1).text()
      ap name
      url = browser.div(class: "a-box-group", index: idx).element(class: "a-box", index: 1).a(class: "a-link-normal", index: 1).href
      ap url
      purchased_at = browser.div(class: "a-box-group", index: idx).element(class: ["a-color-secondary", "value"], index: 0).text()
      ap purchased_at
      price = browser.div(class: "a-box-group", index: idx).element(class: ["a-color-secondary", "value"], index: 1).text().delete("￥").delete(",").strip
      ap price
      hash = {}
      hash["name"] = name
      hash["url"] = url
      hash["purchased_at"] = purchased_at
      hash["price"] = price
      array << hash
    end

    if browser.element(class: "a-last").a.exists?
      next_url = browser.element(class: "a-last").a.href
      browser.goto(next_url)
      browser.wait
      self.scrape_history(browser, array)
    end

    array
  end

  def self.download_receipt(browser)
    page_item_count = browser.divs(class: "a-box-group").count
    for idx in 0..(page_item_count - 1) do
      browser.div(class: "a-box-group", index: idx).scroll.to


      browser.div(class: "a-box-group", index: idx).elements(class: "a-popover-trigger").last.click
      browser.div(class: "a-popover").elements(class: "a-list-item").last.wait_until(&:present?).click
      browser.wait
      browser.as.first.click
      browser.wait
      browser.back
      browser.back
    end

    if browser.element(class: "a-last").a.exists?
      next_url = browser.element(class: "a-last").a.href
      browser.goto(next_url)
      browser.wait
      self.download_receipt(browser)
    end



    browser
  end

  def self.login_and_batch_scrape
    browser = self.login
    array = []
    years = [2019, 2018, 2017]
    # years = [2020,2016]
    years.each do |year|
      self.goto_history(browser, year)
      array.concat(self.scrape_history(browser))
    end
    array
  end

  def self.login_and_batch_download
    browser = self.login
    years = [2019, 2018, 2017]
    years.each do |year|
      self.goto_history(browser, year)
      self.download_receipt(browser)
    end
  end

end