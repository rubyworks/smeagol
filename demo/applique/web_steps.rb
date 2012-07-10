def get_content(body)
  body = body.gsub(/^.+<article>\n/m, '')
  body = body.gsub(/\n<\/article>.+$/m, '')
  return body
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
