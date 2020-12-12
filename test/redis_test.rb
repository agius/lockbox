require_relative "test_helper"

class RedisTest < Minitest::Test
  def setup
    redis.flushall
  end

  def test_set_get
    encrypted_redis.set("hello", "world")
    assert_equal "world", encrypted_redis.get("hello")
    refute_equal "world", redis.get("hello")
  end

  def test_get_missing
    assert_nil encrypted_redis.get("hello")
    assert_nil redis.get("hello")
  end

  def test_mset_mget
    encrypted_redis.mset("k1", "v1", "k2", "v2")
    assert_equal ["v1", "v2", nil], encrypted_redis.mget("k1", "k2", "missing")
    refute_equal "v1", redis.get("k1")
    refute_equal "v2", redis.get("k2")
  end

  def redis
    @redis ||= Redis.new(logger: $logger)
  end

  def encrypted_redis
    @encrypted_redis ||= Lockbox::Redis.new(
      key: Lockbox.generate_key,
      blind_index_key: BlindIndex.generate_key,
      logger: $logger
    )
  end
end
