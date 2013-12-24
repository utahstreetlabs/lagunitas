require 'bundler'
require 'yaml'

# Bundler >= 1.0.10 uses Psych YAML, which is broken, so fix that.
# https://github.com/carlhuda/bundler/issues/1038
YAML::ENGINE.yamler = 'syck'

Bundler.require

$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

ENV['RACK_ENV'] ||= 'development'

class Lagunitas < Thor
  CONFIG = File.join('config', 'mongoid.yml')

  desc "rebuild_from_staging", "rebuilds the development database from staging"
  def rebuild_from_staging
    dev = config['development']
    st = config['staging']
    run_command(%Q/mongo #{dev['database']} --eval "db.runCommand('dropDatabase')"/)
    run_command(%Q/mongo #{dev['database']} --eval "db.copyDatabase('#{st['database']}', '#{dev['database']}', '#{st['host']}')"/)
  end

  desc 'migrate_viewed_notifications', 'marks all notifications older than a week as viewed'
  def migrate_viewed_notifications
    load_mongoid
    require 'lagunitas/models'
    require 'progress_bar'

    before = 1.week.ago.utc
    scope = Notification.where(:created_at.lte => before, :viewed_at => nil)

    count = scope.count
    say_trace "Marking #{count} notifications read that were created before #{before}"
    progress = ProgressBar.new(count)

    # upate each notification separately so as to not hold the global write lock while updating millions of documents
    now = Time.now.utc
    scope.each do |notification|
      notification.viewed_at = now
      notification.save!
      begin
        progress.increment!
      rescue; end
    end
  end

  desc 'migrate_reply_email_settings', 'Opts users out of the reply email who are opted out of the comment email'
  def migrate_reply_email_settings
    load_mongoid
    require 'lagunitas/models/preferences'
    require 'progress_bar'

    scope = Preferences.where(email_opt_outs: "listing_comment")
    count = scope.count
    say_trace "Migrating listing_comment_reply email opt-out setting for #{count} users"
    progress = ProgressBar.new(count)

    # upate each prefs separately so as to not hold the global write lock while updating thousands of documents
    scope.each do |prefs|
      prefs.add_to_set(:email_opt_outs, "listing_comment_reply")
      begin
        progress.increment!
      rescue; end
    end
  end

protected
  def load_mongoid
    Mongoid.load!(CONFIG)
    Mongoid.logger = Logger.new(File.join('log', "#{ENV['RACK_ENV']}.log"))
  end

  def config
    @config ||= YAML.load_file(CONFIG)
  end

  def run_command(command)
    say_status :run, command
    IO.popen("#{command} 2>&1") do |f|
      while line = f.gets do
        puts line
      end
    end
  end

  def say_ok(msg)
    say_status :OK, msg, :green
  end

  def say_trace(msg)
    say_status :TRACE, msg, :blue
  end

  def say_error(msg)
    say_status :ERROR, msg, :red
  end
end
