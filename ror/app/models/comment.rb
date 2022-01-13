class Comment < ApplicationRecord
  belongs_to :article

  scope :with_status, ->(status = self.SUBMIT_STATUS[:approved]) { where("submit_status = '#{status}'") }

  SUBMIT_STATUS = {
    submitted: 'submitted',
    approved:  'approved',
    flagged:   'flagged'
  }.freeze

end
