require 'spec_helper'

RSpec.describe SchemaPoweredModels::Model do
  let(:factory) { TestModel }
  subject { factory.new(RDF::URI("http://test.com"), title: "Test") }
  let(:schema) do
    {
      title: RDF::URI("http://test.com/title")
    }
  end

  before do
    class TestModel < SchemaPoweredModels::Model
    end
    TestModel.schema = schema
  end

  after do
    Object.send(:remove_const, :TestModel)
  end

  describe "basic initialization" do
    it "can process attributes provided in the schema" do
      expect(subject.title).to eq "Test"
    end
  end

  describe ".from_graph" do
    it "can translate properties from a graph" do
      graph = RDF::Repository.new
      graph << [RDF::URI("http://test.com"), RDF::URI("http://test.com/title"), "test"]

      result = factory.from_graph(subject: RDF::URI("http://test.com"), graph: graph)
      expect(result.title).to eq [ "test" ]
    end
  end
end
