# redis の実験

redis の　download https://redis.io/download

redis の排他処理で watch を使う。

ここを参考にした
https://www.xmisao.com/2020/04/12/redis-transaction-and-optimistic-locking-in-ruby.html

```bash
bundle install

redis-server // redisを起動してなければ

ruby main.rb

ruby threads.rb
```
