require 'logger'
require 'coinbase' #gem 'coinbase'
require 'mail' # gem 'mail'

BUY_CEIL = Money.new(56500, "USD")
SELL_FLOOR = Money.new(80000, "USD")
AUTO_BUY = true
AUTO_SELL = true
BUY_QUANTITY = 1
SELL_QUANTITY = 1

EMAIL_ALERT_ADDRESS = 'dokkaebi@gmail.com'
SLEEP_SECONDS = 30 # seconds between API calls

I18n.enforce_available_locales = false

dir = File.dirname(__FILE__)

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

# email_login.yml example:

# ---
# :username: user@gmail.com
# :password: pass
#
# email_login = YAML.load_file(File.join(dir, "email_login.yml"))
coinbase_api = YAML.load_file(File.join(dir, "api_key.yml"))
coinbase = Coinbase::Client.new(coinbase_api[:api_key], coinbase_api[:api_secret])

email_login = YAML.load_file(File.join(dir, "email_login.yml"))
email_address = email_login[:user_name]

Mail.defaults do
  delivery_method :smtp, email_login.merge(
    address:              "mail.sungwonchoe.com",
    port:                 "587",
    authentication:       :login,
    enable_starttls_auto: true,
    openssl_verify_mode:  'none' 
  )
end

def send_notice(from, subject, body)
  Mail.deliver do
  	to      EMAIL_ALERT_ADDRESS
    from    from
    subject subject
    body    body
  end
end

loop do

  begin
    buy_price = coinbase.buy_price(1)
    sell_price = coinbase.sell_price(1)
  rescue Exception => e
    puts e.message
    next
  end
  
  logger.debug "Buy Price: $ #{buy_price}"
  logger.debug "Sell Price: $ #{sell_price}"
  puts(Time.now.inspect + " | Total Buy Price: " + buy_price.format + " | Total Sell Price: " + sell_price.format) 

  if buy_price <= BUY_CEIL
    if AUTO_BUY
      logger.info "Buy Price ($#{buy_price}) below target ($#{BUY_CEIL}). Buying automatically."
      coinbase.buy!(BUY_QUANTITY);
      send_notice(email_address, "Auto-buy at $#{buy_price}", "Auto-buy at $#{buy_price}")
      break
    else
      logger.info "Buy Price ($#{buy_price}) below target ($#{BUY_CEIL}). Sending alert."
      send_notice(email_address, "Low buy price ($#{buy_price})", "Low buy price ($#{buy_price})")
      break
    end
  elsif sell_price >= SELL_FLOOR
    if AUTO_SELL
      logger.info "Sell Price ($#{sell_price}) below target ($#{SELL_CEIL}). Selling automatically."
      coinbase.sell!(SELL_QUANTITY);
      send_notice(email_address, "Auto-sell at ($#{sell_price})", "Auto-sell at ($#{sell_price})")
      break
    else  
      logger.info "Sell Price ($#{sell_price}) below target ($#{SELL_CEIL}). Sending alert."
      send_notice(email_address, "High sell price ($#{sell_price})", "High sell price ($#{sell_price})")
      break
    end
  end
  sleep SLEEP_SECONDS
end