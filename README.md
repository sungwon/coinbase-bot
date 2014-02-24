coinbase-bot
============

Simple Coinbase price checker Ruby script. 

This program checks the current total buy and sell prices (including fees) on coinbase and sends email alerts to the user at the specified email address or auto-buys or auto-sells at the specified prices.

Parameters can be set with the following constants:

BUY_CEIL = Money.new(56500, "USD")     # buy price ceiling in cents

SELL_FLOOR = Money.new(80000, "USD")   # sell price ceiling in cents

AUTO_BUY = true # if set to true, performs autobuy at buy ceiling or lower. if false, sends email alert

AUTO_SELL = true # if set to true, performs autosell at sell floor or higher. if false, sends email alert

BUY_QUANTITY = 1 # quantity in bitcoins

SELL_QUANTITY = 1 # quantity in bitcoins

EMAIL_ALERT_ADDRESS = username@emaildomain.com # email address to send alerts to

Additionally, 2 yaml configuration files are needed:
email_login.yml
api_key.yml

email_login.yml should look something like this:

---
:user_name: emailtosendfrom@domain.com
:password: passwordforemailtosendfrom

For the API key, you will have to enable one at Coinbase.com for your account and then put in the details like so:

---
:api_key: stringoflettersandnumbers
:api_secret: stringoflettersandnumbers

Contact me with any questions.
