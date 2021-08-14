require "bundler"
Bundler.require

redis = Redis.new

key = "111"
redis.multi do
  pp "---key: #{key} を設定する---"
  redis.hset(key, { id: 1, value: "hello world" })
  pp "---有効期限を5秒に設定する---"
  redis.expire(key, 5)
end

pp "---設定直後は値が見れる---"
pp redis.hgetall(key)

pp "---5秒待つ---"
sleep 5

pp "---消える---"
pp redis.hgetall(key)
