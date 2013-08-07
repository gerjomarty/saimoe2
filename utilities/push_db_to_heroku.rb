#!/usr/bin/env ruby

require 'optparse'

hostname = 'localhost'
soulmate = regen_database = false
username = db_name = dropbox = nil

opts = OptionParser.new do |opts|
  opts.banner = "#{$PROGRAM_NAME} OPTIONS"
  opts.separator ''

  opts.on('-H', '--host HOST', String, 'Database hostname', "(#{hostname})") {|h| hostname = h}
  opts.on('-u', '--user USERNAME', String, 'Database username') {|u| username = u}
  opts.on('-n', '--name DB_NAME', String, 'Database name') {|n| db_name = n}
  opts.on('-d', '--dropbox FOLDER', String, 'Dropbox folder to dump to - must be public') {|d| dropbox = d.chomp('/')}
  opts.on('-g', '--[no-]regenerate-database', 'Regenerate the database from the base data first', "(#{regen_database})") {|g| regen_database = g}
  opts.on('-s', '--[no-]soulmate', 'Generate Soulmate keys on Heroku', "(#{soulmate})") {|s| soulmate = s}
  opts.on('-h', '--help', 'Display these options') {puts opts; exit 1}
end
opts.parse!

unless hostname && username && db_name && dropbox
  $stderr.puts opts
  exit 1
end

unless File.directory? dropbox
  $stderr.puts "Error: Folder #{dropbox} does not exist or is not a directory"
  exit 1
end

if regen_database
  $stdout.puts "Regenerating the database from the base YAML data..."
  unless system("rake db:drop && rake db:create && rake db:migrate && rake db:seed")
    $stderr.puts "Error when regenerating database: #{$?}"
    exit 1
  end
end

$stdout.puts "Dumping database to #{dropbox}..."
unless system("pg_dump -Fc --no-acl --no-owner -h #{hostname} -U #{username} #{db_name} > #{dropbox}/#{db_name}.dump")
  $stderr.puts "Error when dumping database: #{$?}"
  exit 1
end

unless system("open #{dropbox}")
  $stderr.puts "Error opening Dropbox folder. This was only written to work with MacOS X."
end

print "Enter URL of file: "
$stdout.flush
url = gets.chomp

$stdout.puts "Dumping database to Heroku..."
unless system("heroku pgbackups:restore DATABASE '#{url}'")
  $stderr.puts "Error when restoring database: #{$?}"
  exit 1
end

$stdout.puts "Removing dump file from #{dropbox}..."
unless system("rm -rf #{dropbox}/#{db_name}.dump")
  $stderr.puts "Error when deleting dump file: #{$?}"
  exit 1
end

$stdout.puts "Pushing latest code to Heroku..."
unless system("git push heroku master")
  $stderr.puts "Error pushing to Heroku: #{$?}"
  exit 1
end

if soulmate
  $stdout.puts "Generating Soulmate keys on Heroku..."
  unless system("heroku run console production utilities/generate_soulmate_keys.rb")
    $stderr.puts "Error when generating Soulmate keys: #{$?}"
    exit 1
  end
end
