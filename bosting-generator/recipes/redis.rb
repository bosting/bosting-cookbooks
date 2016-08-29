%w(redis hiredis).each do |name|
  chef_gem name do
    compile_time true
  end
  require name
end

$redis = Redis.new(driver: :hiredis)
