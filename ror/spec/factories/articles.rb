FactoryBot.define do

  factory :article do
    title  { 'factory article title' }
    body   { 'factory article body' }
    status { 'public' }
  end
end