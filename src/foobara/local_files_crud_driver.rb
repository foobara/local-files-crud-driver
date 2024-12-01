require "fileutils"

module Foobara
  # TODO: lots of duplication in this file. Need to DRY this up a bit.
  class LocalFilesCrudDriver < Persistence::EntityAttributesCrudDriver
    attr_accessor :data_path, :format, :fsync, :multi_process

    def initialize(data_path: "#{Dir.pwd}/local_data/records.yml", format: :yaml, fsync: false, multi_process: false)
      self.data_path = data_path
      self.format = format
      self.fsync = fsync
      self.multi_process = multi_process

      unless format == :yaml
        # :nocov:
        raise ArgumentError, "Only :yaml format is supported for now"
        # :nocov:
      end

      super
    end

    class Table < Persistence::EntityAttributesCrudDriver::Table
      def get_id
        with_writeable_raw_data do |raw_data|
          table_data = raw_data[table_name] ||= {}
          sequence_value = table_data["sequence"] || 1
          table_data["sequence"] = sequence_value + 1

          sequence_value
        end
      end

      def all
        with_readable_raw_data do |raw_data|
          raw_data[table_name]&.[]("records")&.values || []
        end
      end

      def count
        with_readable_raw_data do |raw_data|
          raw_data[table_name]&.[]("records")&.size || 0
        end
      end

      def find(record_id)
        with_readable_raw_data do |raw_data|
          raw_data[table_name]&.[]("records")&.[](record_id)
        end
      end

      # TODO: move this up to base class as a default
      def find!(record_id)
        attributes = find(record_id)

        unless attributes
          # :nocov:
          raise CannotFindError.new(record_id, "does not exist")
          # :nocov:
        end

        attributes
      end

      def insert(attributes)
        attributes = Util.deep_dup(attributes)
        record_id = record_id_for(attributes)

        unless record_id
          record_id = get_id
          attributes.merge!(primary_key_attribute => record_id)
        end

        with_writeable_raw_data do |raw_data|
          table_data = raw_data[table_name] ||= {}
          records = table_data["records"] ||= {}

          if record_id
            if records.key?(record_id)
              # :nocov:
              raise CannotInsertError.new(record_id, "already exists")
              # :nocov:
            end
          end

          records[record_id] = attributes
        end

        Util.deep_dup(attributes)
      end

      def update(attributes)
        with_writeable_raw_data do |raw_data|
          attributes = Util.deep_dup(attributes)

          record_id = record_id_for(attributes)

          table_data = raw_data[table_name] ||= {}
          records = table_data["records"] ||= {}

          unless records.key?(record_id)
            # :nocov:
            raise CannotUpdateError.new(record_id, "does not exist")
            # :nocov:
          end

          records[record_id] = attributes
        end

        Util.deep_dup(attributes)
      end

      def hard_delete(record_id)
        with_writeable_raw_data do |raw_data|
          table_data = raw_data[table_name] ||= {}
          records = table_data["records"] ||= {}

          unless records.key?(record_id)
            # :nocov:
            raise CannotDeleteError.new(record_id, "does not exist")
            # :nocov:
          end

          records.delete(record_id)
        end
      end

      def hard_delete_all
        with_writeable_raw_data do |raw_data|
          table_data = raw_data[table_name] ||= {}
          table_data["records"] = {}
        end
      end

      private

      def data_path
        crud_driver.data_path
      end

      def multi_process
        crud_driver.multi_process
      end

      # TODO: rename
      def with_readable_raw_data(load: multi_process, mode: "r", lock: File::LOCK_SH, &)
        if load
          unless File.exist?(data_path)
            raw_data = {}
            return yield raw_data
          end

          FileUtils.mkdir_p File.dirname(data_path)

          File.open(data_path, mode) do |f|
            f.flock(lock)
            yaml = f.read
            raw_data = yaml.empty? ? {} : YAML.load(yaml)
            @raw_data = raw_data unless multi_process
            yield raw_data, f
          end
        elsif defined?(@raw_data)
          yield @raw_data
        else
          with_readable_raw_data(load: true, lock:, mode:, &)
        end
      end

      def with_writeable_raw_data
        retval = nil

        with_readable_raw_data(mode: "r+", lock: File::LOCK_EX) do |raw_data, f|
          if f
            retval = yield raw_data, f
            f.truncate(0)
            f.rewind
            f.write(YAML.dump(raw_data))
          else
            FileUtils.mkdir_p File.dirname(data_path)

            File.open(data_path, "w") do |f|
              f.flock(File::LOCK_EX)
              retval = yield raw_data, f
              f.write(YAML.dump(raw_data))
            end
          end

          unless multi_process
            @raw_data = raw_data
          end
        end

        retval
      end
    end
  end
end
