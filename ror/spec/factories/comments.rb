FactoryBot.define do

  factory :comment do
    commenter     { 'factory comment commenter' }
    body          { 'factory comment body' }
    submit_status { 'submitted' }

    association :article
  end
end