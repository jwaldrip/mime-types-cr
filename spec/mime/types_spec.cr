require "spec"
require "../src/mime-types"

describe MIME::Types do
  describe "macro: load" do
    it "should load types from a json file" do
    end
  end

  describe ".register" do
    it "should regsiter a new mime type" do
    end
  end

  describe ".[]" do
    it "should select matching types" do
    end
  end

  describe ".type_for(filename : String)" do
    it "should select matching types by filename" do
      MIME::Types.type_for("foo.js").should contain "application/javascript"
    end
  end

  describe ".for_extension" do
    it "should select matching types by extension" do
    end
  end

  describe ".registered" do
    it "should list all registered MIME::Types" do
    end
  end

  describe ".each" do
    it "should delegate to CACHE" do
    end
  end
end
