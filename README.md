# Action throttling

## Usage

```
gem 'rails-action_throtling'
```

Configure your bucket. There are no default values for this, since we can't know your application specific implementation, so this step is mandatory.

```ruby
ActionThrottling.configure do |config|
  # The bucket is evaluated inside your application context, so the object must
  # respond to call. The resulting object must respond to `deduct` to deduct the
  # cost.
  config.bucket = Proc.new { current_user.bucket }

  # Configure how fast the bucket regenerates.
  # The `interval` determines the interval at which the `bucket` regains
  # `amount` credit.
  config.regenerate = Proc.new do
    {
      interval: current_user.bucket.regeneration_interval, # 1.minute
      amount: current_user.bucket.regeration_amount, # 10
    }
  end
end
```

Then call the `cost` method on your actions that you want to protect:

```ruby
def show
  # Every call will cost one credit
  # Based on the configuration above, this will allow the user to call this
  # endpoint 100 times every minute.
  #
  # This will call the `deduct(1)` method on the configured `config.bucket` (see
  # above)
  cost 1
  # ...
end
```

If you have something like a create method, or some complex method that's costly on the server side, you can set the cost appropriately:

```ruby
def complex_method
  # This will call `deduct(25)` on the `config.bucket` (see above)
  cost 25
  # ...
end
```
