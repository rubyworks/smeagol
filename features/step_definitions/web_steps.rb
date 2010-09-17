def get_content(body)
  lines = body.split(/\n/)
  puts "#{lines.length}"
  lines.slice(10, lines.length-13).join("\n")
end

When /^I go to "([^"]*)"$/ do |url|
  get url
end

Then /^I should see the following:$/ do |body|
  body = body.gsub(/^\s+| +$/, '')
  response_body = last_response.body.gsub(/^\s+| +$/, '')
  response_body.should == body
end

Then /^I should see the following content:$/ do |body|
  body = body.gsub(/^\s+/, '')
  response_body = get_content(last_response.body.gsub(/^\s+/, ''))
  response_body.should == body
end
