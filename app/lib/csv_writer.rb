require 'csv'
class CsvWriter
  def self.generate_report

    items = AmazonBrowser.login_and_batch_scrape
    CSV.open('purchase_items.csv', 'w') do |csv|
      csv << ["購入日","商品名", "商品URL", "金額"]
      items.each do |item|
        csv << [item["purchased_at"], item["name"], item["url"], item["price"]]
      end
    end
  end
end