FactoryGirl.define do
  factory :participant do
    sequence(:name) { |n| "Participant #{n}" }
    sequence :number
    bus
  end
end
