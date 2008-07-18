require File.dirname(__FILE__) + '/../spec_helper'

describe ZoneTemplate, "when new" do
  fixtures :all
  
  before(:each) do
    @zone_template = ZoneTemplate.new
  end

  it "should be invalid by default" do
    @zone_template.should_not be_valid
  end
  
  it "should require a name" do
    @zone_template.should have(1).error_on(:name)
  end
  
  it "should have a unique name" do
    @zone_template.name = "East Coast Data Center"
    @zone_template.should have(1).error_on(:name)
  end
  
  it "should require a TTL" do
    @zone_template.ttl = nil
    @zone_template.should have(1).error_on(:ttl)
  end
  
  it "should not require optional owner" do
    @zone_template.should have(:no).errors_on(:user_id)
  end
end

describe ZoneTemplate, "when loaded" do
  fixtures :all
  
  before(:each) do
    @zone_template = zone_templates( :east_coast_dc )
  end
  
  it "should have record templates" do
    @zone_template.record_templates.should_not be_empty
  end
  
  it "should provide an easy way to build a zone" do
    zone = @zone_template.build('example.org')
    zone.should be_a_kind_of( Zone )
    zone.should be_valid
  end
  
  it "should have a sense of validity" do
    @zone_template.has_soa?.should be_true
    
    zone_templates( :partially_complete ).has_soa?.should_not be_true
  end
end

describe ZoneTemplate, "when used to build a zone" do
  fixtures :all
  
  before(:each) do
    @zone_template = zone_templates( :east_coast_dc )
    @zone = @zone_template.build( 'example.org' )
  end
  
  it "should create a valid new zone" do
    @zone.should be_valid
    @zone.should be_a_kind_of( Zone )
  end
  
  it "should create the correct number of records (from templates)" do
    @zone.records.size.should eql( @zone_template.record_templates.size )
  end
  
  it "should create a SOA record" do
    soa = @zone.soa_record
    soa.should_not be_nil
    soa.should be_a_kind_of( SOA )
    soa.primary_ns.should eql('ns1.example.org.')
  end
  
  it "should create two NS records" do
    ns = @zone.ns_records
    ns.should be_a_kind_of( Array )
    ns.size.should be(2)
    
    ns.each { |r| r.should be_a_kind_of( NS ) }
  end
  
end

describe ZoneTemplate, "when used to build a zone for a user" do
  fixtures :all
  
  before(:each) do
    @user = users(:quentin)
    @zone_template = zone_templates( :quentin_home )
    @zone = @zone_template.build( 'example.org', @user )
  end
  
  it "should create a valid new zone" do
    @zone.should be_valid
    @zone.should be_a_kind_of( Zone )
  end
  
  it "should be owned by the user" do
    @zone.user.should be( @user )
  end
  
  it "should create the correct number of records (from templates)" do
    @zone.records.size.should eql( @zone_template.record_templates.size )
  end
  
  it "should create a SOA record" do
    soa = @zone.soa_record
    soa.should_not be_nil
    soa.should be_a_kind_of( SOA )
    soa.primary_ns.should eql('ns1.example.com.')
  end
  
  it "should create two NS records" do
    ns = @zone.ns_records
    ns.should be_a_kind_of( Array )
    ns.size.should be(2)
    
    ns.each { |r| r.should be_a_kind_of( NS ) }
  end
  
  it "should create the correct CNAME's from the template" do
    cnames = @zone.cname_records
    cnames.size.should be(2)
  end
  
end

describe ZoneTemplate, "and finders" do
  fixtures :all
  
  it "should be able to return all templates" do
    ZoneTemplate.find(:all).size.should be( ZoneTemplate.count )
  end
  
  it "should respect required validations" do
    ZoneTemplate.find(:all, :require_soa => true).size.should be( 3 )
  end
end