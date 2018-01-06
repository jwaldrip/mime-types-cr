require "../spec_helper"

describe MIME::Type do
  describe ".match" do
    context "if matched" do
      it "should return MatchData" do
        MIME::Type.match("some/type").should be_a(Regex::MatchData)
      end
    end

    context "if not matched" do
      it "should return nil" do
        MIME::Type.match("bad").should be_nil
      end
    end
  end

  describe ".simplified" do
    context "remove_x = true" do
      it "should downcase" do
        MIME::Type.simplified("X-foo/X-bar", remove_x: true).should eq "foo/bar"
      end
    end

    it "should downcase" do
      MIME::Type.simplified("X-foo/X-bar").should eq "x-foo/x-bar"
    end
  end

  describe "#initialize" do
    context "given an invalid content_type" do
      it "should raise an InvalidContentType exception" do
        expect_raises(MIME::Type::InvalidContentType, "Invalid Content-Type \"bad\"") do
          MIME::Type.new("bad")
        end
      end
    end

    context "with extensions" do
      it "should register with extensions" do
        mime_type = MIME::Type.new("some/type", ["se"])
        mime_type.extensions.should eq Set.new(["se"])
        mime_type.content_type.should eq "some/type"
      end
    end
  end

  describe "#encoding=" do
    context "with an invalid encoding" do
      it "should raise an InvalidEncoding exception" do
        expect_raises(MIME::Type::InvalidEncoding) do
          MIME::Type.new("some/type", encoding: "foo")
        end
      end
    end
  end

  describe "#preferred_extension" do
    it "should be the first extension in the list" do
      mime_type = MIME::Type.new("some/type", ["st", "tt"])
      mime_type.preferred_extension.should eq "st"
    end
  end

  describe "#preferred_extension=" do
    it "should set the preferred_extension" do
      mime_type = MIME::Type.new("some/type", ["st"])
      mime_type.preferred_extension = "tt"
      mime_type.preferred_extension.should eq "tt"
    end
  end

  describe "#media_type" do
    context "with an x-type" do
      it "should return the correct media_type" do
        MIME::Type.new("x-Hello/x-World").media_type.should eq "x-hello"
      end
    end
  end

  describe "#raw_media_type" do
    context "with an x-type" do
      it "should return the correct media_type" do
        MIME::Type.new("x-Hello/x-World").raw_media_type.should eq "x-Hello"
      end
    end
  end

  describe "#sub_type" do
    context "with an x-type" do
      it "should return the correct media_type" do
        MIME::Type.new("x-Hello/x-World").sub_type.should eq "x-world"
      end
    end
  end

  describe "#raw_sub_type" do
    context "with an x-type" do
      it "should return the correct media_type" do
        MIME::Type.new("x-Hello/x-World").raw_sub_type.should eq "x-World"
      end
    end
  end

  describe "#ascii?" do
    context "when ascii" do
      it "should return true" do
        mime_type = MIME::Type.new("foo/bar", encoding: "7bit")
        mime_type.ascii?.should be_true
      end
    end

    context "when not ascii" do
      it "should return false" do
        mime_type = MIME::Type.new("foo/bar", encoding: "base64")
        mime_type.ascii?.should be_false
      end
    end
  end

  describe "#binary?" do
    context "when binary" do
      it "should return true" do
        mime_type = MIME::Type.new("foo/bar", encoding: "base64")
        mime_type.binary?.should be_true
      end
    end

    context "when not binary" do
      it "should return false" do
        mime_type = MIME::Type.new("foo/bar", encoding: "7bit")
        mime_type.binary?.should be_false
      end
    end
  end

  describe "#use_instead" do
  end

  describe "#xref_urls" do
  end

  describe "#like?" do
  end

  describe "#eql?" do
    context "when a MIME::Type" do
    end

    context "when not a MIME::Type" do
    end
  end

  describe "#==" do
    context "when a MIME::Type" do
    end

    context "when a string" do
    end

    context "when anything else" do
    end
  end

  describe "#<=>" do
    context "when a MIME::Type" do
      it "should compare with the simplified string" do
      end
    end

    context "when nil" do
      it "should return -1" do
      end
    end

    context "when anything else" do
      it "should compare with the string value" do
      end
    end
  end

  describe "#simplified" do
    context "with x removed" do
      it "should remove downcased with x removed" do
      end
    end

    it "should return downcased" do
    end
  end

  describe "#priority_compare" do
    context "when a MIME::Type" do
    end

    context "when a String" do
    end
  end

  describe "#set_friendly" do
    context "with a lang" do
      it "should set the friendly language" do
        mime_type = MIME::Type.new("some/string")
        mime_type.set_friendly("hola", lang: "sp")
        mime_type.friendly(lang: "sp").should eq("hola")
      end
    end

    it "should set the friendly language" do
      mime_type = MIME::Type.new("some/string")
      mime_type.set_friendly("hello")
      mime_type.friendly.should eq("hello")
    end
  end
end
