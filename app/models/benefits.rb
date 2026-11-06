# frozen_string_literal: true
class Benefits < ApplicationRecord

  def self.save(file, backup = false)
    data_path = Rails.root.join("public", "data")
    safe_name = validated_filename(file.original_filename)
    full_file_name = data_path.join(safe_name)
    f = File.open(full_file_name, "wb+")
    f.write file.read
    f.close
    make_backup(safe_name, data_path, full_file_name) if backup == "true"
  end

  def self.make_backup(file_name, data_path, full_file_name)
    if File.exist?(full_file_name)
      silence_streams(STDERR) { system("cp #{full_file_name} #{data_path}/bak#{Time.zone.now.to_i}_#{file_name}") }
    end
  end

  def self.validated_filename(original_filename)
    safe_name = File.basename(original_filename.to_s)
    if safe_name.blank? || safe_name != original_filename.to_s || [".", ".."].include?(safe_name)
      raise ArgumentError, "invalid filename"
    end

    safe_name
  end

  def self.silence_streams(*streams)
    on_hold = streams.collect { |stream| stream.dup }
    streams.each do |stream|
      stream.reopen(RUBY_PLATFORM =~ /mswin/ ? "NUL:" : "/dev/null")
      stream.sync = true
    end
    yield
  ensure
    streams.each_with_index do |stream, i|
      stream.reopen(on_hold[i])
    end
  end
end
