require "bundler"
Bundler.require

pp "--- 排他処理を入れないとカウントアップが正しくない ---"
key1 = "nowatch"
Redis.new.multi do
  Redis.new.set(key1, 0)
  Redis.new.expire(key1, 60)
end

pp "--- 10,000回incrementする処理を2つ並行して行う ---"
threads = Array.new(2).map do
  Thread.start do
    redis = Redis.new

    10_000.times do
      v = redis.get(key1).to_i + 1
      redis.set(key1, v)
    end
  end
end

threads.each(&:join)
pp "--- 20,000が表示されるのを期待するが全然足りないはず ---"

pp Redis.new.get(key1)

pp "--- 排他処理を入れずincrementメソッドを呼び出す ---"
key2 = "increment"
Redis.new.multi do
  Redis.new.set(key2, 0)
  Redis.new.expire(key2, 60)
end

pp "--- 10,000回incrementする処理を2つ並行して行う ---"
threads = Array.new(2).map do
  Thread.start do
    redis = Redis.new

    10_000.times do
      redis.incr(key2)
    end
  end
end

threads.each(&:join)
pp "--- 20,000が表示される。incr,decrを使うのが安全 ---"

pp Redis.new.get(key2)

pp "--- hsetで排他処理を入れてincrement ---"
key3 = "watch"
Redis.new.multi do
  Redis.new.hset(key3, { value: 0 })
  Redis.new.expire(key3, 60)
end

pp "--- 10,000回incrementする処理を2つ並行して行う ---"
threads = Array.new(2).map do
  Thread.start do
    redis = Redis.new

    count = 0
    10_000.times do
      res = redis.watch(key3) do
        v = redis.hgetall(key3)["value"].to_i + 1
        redis.multi do
          redis.hset(key3, { value: v })
        end
      end

      unless res
        count += 1
        redo
      end
    end
    pp "------リトライ回数: #{count} / 10,000----"
  end
end

threads.each(&:join)
pp "--- 20,000が表示される。hsetは必ずwatchを使う ---"
pp "--- リトライ回数が思ったより多い ---"

pp Redis.new.hgetall(key3)
