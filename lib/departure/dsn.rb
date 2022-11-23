module Departure
  # Represents the 'DSN' argument of Percona's pt-online-schema-change
  # See https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html#dsn-options
  class DSN
    # Constructor
    #
    # @param database [String, Symbol]
    # @param table_name [String, Symbol]
    def initialize(database, table_name)
      @database = database
      @table_name = table_name
      @added_dsn_items = ENV.fetch('PERCONA_ADDED_DSN_ITEMS', nil)
    end

    # Returns the pt-online-schema-change DSN string. See
    # https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html#dsn-options
    def to_s
      "D=#{database},t=#{table_name}#{added_dsn_items.nil? ? nil : ',' + added_dsn_items}"
    end

    private

    attr_reader :table_name, :database, :added_dsn_items
  end
end
