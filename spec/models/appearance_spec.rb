require 'spec_helper'

describe Appearance do
  it { should belong_to(:character_role) }
  it { should belong_to(:tournament) }
  it { should have_many(:match_entries) }
  it { should have_many(:voice_actor_roles) }

  it { should validate_presence_of(:character_role_id) }
  it { should validate_numericality_of(:character_role_id).only_integer }
  it { should validate_presence_of(:tournament_id) }
  it { should validate_numericality_of(:tournament_id).only_integer }
end
