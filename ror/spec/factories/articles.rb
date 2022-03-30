FactoryBot.define do

  factory :article do
    title  { |counter| "factory article title #{counter}" }
    body   { 'factory article body' }
    status { 'public' }
  end
end