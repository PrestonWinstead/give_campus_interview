require 'CSV'
require 'json'
class Donation
  attr_accessor :designation_name, :designated_amount, :donor_email
  def initialize(designation_name:, designated_amount:, donor_email:)
    self.designation_name = designation_name
    self.designated_amount = designated_amount
    self.donor_email = donor_email
  end

  def data_object
    {
      designation_name: designation_name,
      designated_amount: designated_amount,
      donor_email: donor_email
    }
  end
end

class LeaderBoard
  attr_accessor :campaign_id, :donations

  def initialize(campaign_id)
    self.campaign_id = campaign_id
    self.donations = []
  end

  def build_display
    display_counts.map do |k, v|
      next if k == nil
      {
        team_supporting: k,
        donor_count: v[:donor_emails].uniq.count,
        raised_amt: v[:total]
      }
    end.compact.sort_by{ |display_item| -display_item[:raised_amt] }
  end

  def display_counts
    designations = {}
    donations.each do |donation|
      designation = designations[donation.designation_name] || { total: 0, donor_emails: [] }
      designation[:total] += donation.designated_amount.to_i
      designation[:donor_emails].push(donation.donor_email)
      designations[donation.designation_name] = designation
    end
    designations
  end

  def data_object
    {
      campaign_id: campaign_id,
      display: build_display
    }
  end
end

class NormalizedDonor
  attr_accessor :campaign_id, :name, :email, :amount, :affiliation, :designation

  def initialize(campaign_id:, name:, email:, amount:, affiliation:, designation:)
    self.campaign_id = campaign_id
    self.name = name
    self.email = email
    self.amount = amount
    self.affiliation = affiliation
    self.designation = designation
  end

  def data_object
    {
      campaign_id: campaign_id,
      name: name,
      email: email,
      amount: amount,
      affiliation: affiliation,
      designation: designation
    }
  end
end

$all_donors = []

def parse_offline_donors
  CSV.foreach('/Users/prestonwinstead/Development/Interviews/GiveCampus/offline-donors.csv', :headers => true) do |row|

    parsed_row = row.to_h
    normalized_donor = NormalizedDonor.new(
      campaign_id: parsed_row['campaign_id'],
      name: parsed_row['name'],
      email: parsed_row['email'],
      amount: parsed_row['amount'],
      affiliation: { parsed_row['affiliation'] => parsed_row['affiliation_value'] },
      designation: { parsed_row['designation_name'] => parsed_row['designated_amount'] }
    )
    $all_donors.push(normalized_donor)
  end
end

def parse_online_donors
  CSV.foreach('/Users/prestonwinstead/Development/Interviews/GiveCampus/online-donors.csv', :headers => true) do |row|
    parsed_row = row.to_h
    normalized_donor = NormalizedDonor.new(
      campaign_id: parsed_row['campaign_id'],
      name: parsed_row['name'],
      email: parsed_row['email'],
      amount: parsed_row['amount'],
      affiliation: JSON.parse(parsed_row['affiliation']),
      designation: JSON.parse(parsed_row['designation'])
    )
    $all_donors.push(normalized_donor)
  end
end

parse_offline_donors
parse_online_donors

$leader_boards = []

$all_donors.each do |donor|
  leader_board = $leader_boards.find{ |leader_board| leader_board.campaign_id == donor.campaign_id }
  puts "donor id #{donor.campaign_id}"
  puts "found leader board #{leader_board&.campaign_id}"
  unless leader_board
    leader_board = LeaderBoard.new(donor.campaign_id)
    $leader_boards.push(leader_board)
  end

  donor.designation.map do |k, v|
    leader_board.donations.push(
      Donation.new(designation_name: k, designated_amount: v, donor_email: donor.email.downcase)
    )
  end
end

puts $leader_boards.map{ |board| board.data_object }
