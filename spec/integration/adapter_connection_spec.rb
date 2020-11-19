require 'spec_helper'
require 'fixtures/migrate/0001_create_column_on_comments'
require 'fixtures/migrate/0002_create_index_on_comments'
require 'fixtures/migrate/0014_change_column_null_true'

describe Departure, integration: true do
  Migration = Struct.new(:class, :version, :uses_departure)

  let(:migration_paths) { [MIGRATION_FIXTURES] }
  let(:direction) { :up }
  let(:migrations) {
    [
        Migration.new(CreateColumnOnComments, 1, false),
        Migration.new(CreateIndexOnComments, 2, true),
        Migration.new(ChangeColumnNullTrue, 14, false),
    ]
  }

  let!(:original_migration_adapter) { ActiveRecord::Migration.original_adapter }
  let!(:original_connection_config_adapter) { ActiveRecord::Base.connection_config[:adapter] }

  def mock_existing_connection
    ActiveRecord::Migration.original_adapter = 'mysql2'
    ActiveRecord::Base.connection_config[:adapter] = 'percona'
  end

  def clean_up_connection_mock
    ActiveRecord::Migration.original_adapter = original_migration_adapter
    ActiveRecord::Base.connection_config[:adapter] = original_connection_config_adapter
  end

  before do
    mock_existing_connection
  end

  after do
    clean_up_connection_mock
  end

  context 'when there are migrations that use departure and migrations that do not' do
    before do
      departure_migrations, non_departure_migrations = migrations.partition(&:uses_departure)
      departure_migrations.each { |migration| migration.class.uses_departure! }
      non_departure_migrations.each { |migration| migration.class.disable_departure! }
    end

    after do
      migrations.each { |migration| migration.class.uses_departure! }
    end

    it 'does not raise an error' do
      expect {
        migrations.each do |migration|
          ActiveRecord::MigrationContext.new(migration_paths, ActiveRecord::SchemaMigration).run(direction, migration.version)
        end
      }.to_not raise_error
    end
  end
end
