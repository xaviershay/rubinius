require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/fixtures/classes.rb'

describe "String#squeeze" do
  it "returns new string where runs of the same character are replaced by a single character when no args are given" do
    "yellow moon".squeeze.should == "yelow mon"
  end
  
  it "only squeezes chars that are in the intersection of all sets given" do
    "woot squeeze cheese".squeeze("eost", "queo").should == "wot squeze chese"
    "  now   is  the".squeeze(" ").should == " now is the"
  end
  
  it "negates sets starting with ^" do
    s = "<<subbookkeeper!!!>>"
    s.squeeze("beko", "^e").should == s.squeeze("bko")
    s.squeeze("^<bek!>").should == s.squeeze("o")
    s.squeeze("^o").should == s.squeeze("<bek!>")
    s.squeeze("^").should == s
    "^__^".squeeze("^^").should == "^_^"
    "((^^__^^))".squeeze("_^").should == "((^_^))"
  end
  
  it "squeezes all chars in a sequence" do
    s = "--subbookkeeper--"
    s.squeeze("\x00-\xFF").should == s.squeeze
    s.squeeze("bk-o").should == s.squeeze("bklmno")
    s.squeeze("b-e").should == s.squeeze("bcde")
    s.squeeze("e-").should == "-subbookkeper-"
    s.squeeze("-e").should == "-subbookkeper-"
    s.squeeze("---").should == "-subbookkeeper-"
    "ook--001122".squeeze("--2").should == "ook-012"
    "ook--(())".squeeze("(--").should == "ook-()"
    s.squeeze("e-b").should == s
    s.squeeze("^e-b").should == s.squeeze
    s.squeeze("^b-e").should == "-subbokeeper-"
    "^^__^^".squeeze("^^-^").should == "^^_^^"
    "^^--^^".squeeze("^---").should == "^--^"
    
    s.squeeze("b-dk-o-").should == "-subokeeper-"
    s.squeeze("-b-dk-o").should == "-subokeeper-"
    s.squeeze("b-d-k-o").should == "-subokeeper-"
    
    s.squeeze("bc-e").should == "--subookkeper--"
    s.squeeze("^bc-e").should == "-subbokeeper-"

    "AABBCCaabbcc[[]]".squeeze("A-a").should == "ABCabbcc[]"
  end
  
  it "taints the result when self is tainted" do
    "hello".taint.squeeze("e").tainted?.should == true
    "hello".taint.squeeze("a-z").tainted?.should == true

    "hello".squeeze("e".taint).tainted?.should == false
    "hello".squeeze("l".taint).tainted?.should == false
  end
  
  it "tries to convert each set arg to a string using to_str" do
    other_string = Object.new
    def other_string.to_str() "lo" end
    
    other_string2 = Object.new
    def other_string2.to_str() "o" end
    
    "hello room".squeeze(other_string, other_string2).should == "hello rom"

    obj = Object.new
    obj.should_receive(:respond_to?, :with => [:to_str], :count => :any, :returning => true)
    obj.should_receive(:method_missing, :with => [:to_str], :returning => "o")
    "hello room".squeeze(obj).should == "hello rom"
  end
  
  it "raises a TypeError when one set arg can't be converted to a string" do
    should_raise(TypeError) { "hello world".squeeze(?o) }
    should_raise(TypeError) { "hello world".squeeze(:o) }
    should_raise(TypeError) { "hello world".squeeze(Object.new) }
  end
  
  it "returns subclass instances when called on a subclass" do
    MyString.new("oh no!!!").squeeze("!").class.should == MyString
  end
end

describe "String#squeeze!" do
  it "modifies self in place and returns self" do
    a = "yellow moon"
    a.squeeze!.equal?(a).should == true
    a.should == "yelow mon"
  end
  
  it "returns nil if no modifications were made" do
    a = "squeeze"
    a.squeeze!("u", "sq").should == nil
    a.squeeze!("q").should == nil
    a.should == "squeeze"
  end

  it "raises a TypeError when self is frozen" do
    a = "yellow moon"
    a.freeze

    should_raise(TypeError) { a.squeeze!("") }
    should_raise(TypeError) { a.squeeze! }
  end
end
