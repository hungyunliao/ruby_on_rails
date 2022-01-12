FactoryBot.define do

  factory :comment do
    commenter  { 'factory comment commenter' }
    body       { 'factory comment body' }
    article_id { 1 }
  end
end