module SchemaPoweredModels
  class Attributes
    attr_reader :graph
    def initialize(graph)
      @graph = graph
    end

    def to_h
      Hash[
        nested_graph.map do |subject, vals|
          [subject, Hash[vals]]
        end
      ]
    end

    private

      def nested_graph
        graph.each_statement.group_by(&:subject).map do |subject, statement|
          [subject, nested_objects(statement)]
        end
      end

      def nested_objects(statement)
        statement.group_by(&:predicate).map do |predicate, st|
          [predicate, st.map(&:object)]
        end
      end
  end

  class GraphConverter
    attr_reader :schema
    def initialize(schema)
      @schema = schema
    end

    def from_graph(graph)
      return {} if graph.nil?
      schema.each do |key, predicate|
        if graph[predicate]
          graph[key] = graph.delete(predicate)
        end
      end
      graph
    end
  end
  class Model
    class << self
      attr_reader :schema
      def schema=(schema)
        @schema = schema
        return unless schema
        schema.each do |key, value|
          define_method key do
            attributes[key]
          end
          define_method :"#{key}=" do |v|
            attributes[key] = v
          end
        end

        def from_graph(subject:, graph:)
          # There's gotta be a better way to do this, especially since
          # RDF::Repository has a really fast internal hash for this kind of
          # access.
          attrs = Attributes.new(graph).to_h
          attrs = GraphConverter.new(schema).from_graph(attrs[subject])
          new(subject, attrs)
        end
      end
    end

    attr_reader :attributes, :subject
    def initialize(subject, attributes = {})
      @subject = subject
      @attributes = attributes
    end
  end
end
