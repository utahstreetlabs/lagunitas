require 'spec_helper'
require 'lagunitas/resource/root'

describe Lagunitas::Root do
  context "#nuke" do
    it "clears everything" do
      Lagunitas::Root.expects(:fire_delete).with('/').once
      Lagunitas::Root.nuke
    end
  end
end
