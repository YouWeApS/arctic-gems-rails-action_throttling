# Action throttling

## Usage

```
gem 'rails-action_throtling'
```

Configure your bucket. There are no default values for this, since we can't know your application specific implementation, so this step is mandatory.

```ruby
ActionThrottling.configure do |config|
  # The bucket_key is evaluated inside your application context
  config.bucket_key = Proc.new { current_user.id }

  # Set the interval in which the bucket is regenerated
  config.regenerate_interval = Proc.new { current_user.regenerate_interval }

  # Sets the number of tokens to be put back into the bucket
  config.regenerate_amount = Proc.new { current_user.regenerate_amount }

  # (optional) If you're not running on a completely vanilla redis connection,
  # you can supply your own redis instance here.
  config.redis = Redis.new 'http://redis-server.com'
end
```

Then call the `cost` method on your actions that you want to protect:

```ruby
def show
  # Every call will cost one credit
  # Based on the configuration above, this will allow the user to call this
  # endpoint 100 times every minute.
  #
  # This will call the `deduct(1)` method on the configured `config.bucket_key` (see
  # above)
  cost 1
  # ...
end
```

If you have something like a create method, or some complex method that's costly on the server side, you can set the cost appropriately:

```ruby
def complex_method
  # This will call `deduct(25)` on the `config.bucket_key` (see above)
  cost 25
  # ...
end
```
