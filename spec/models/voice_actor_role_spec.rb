require 'spec_helper'

describe VoiceActorRole do
  it { should belong_to(:appearance) }
  it { should belong_to(:voice_actor) }

  it { should validate_presence_of(:appearance_id) }
  it { should validate_presence_of(:voice_actor_id) }

  it "should not care about presence of voice actor when it has none" do
    var = build :voice_actor_role, voice_actor_id: nil, has_no_voice_actor: true
    var.valid?.should be_true
  end
end
