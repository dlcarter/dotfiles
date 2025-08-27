#!ruby

# Simple focus timer, written by Derek Carter

require 'colorize'

NUM_MINUTES = 25
OVERWRITE_LINE = "\e[1A\e[K"

BLOCK = "█"
BLOCK_CHARS = "▎▍▌▋▊▉"
THRESHOLD_YELLOW = 50 # Percentage of time remaining at which to turn timer yellow
THRESHOLD_RED = 20 # Percentage of time remaining at which to turn timer red

class Timer

  def help
    puts "Usage: timer [minutes:seconds] [label]"
    puts
    puts "Examples:"
    puts "  Start a 25 minute timer:"
    puts "    timer"
    puts "  Start a 10 minute timer:"
    puts "    timer 10"
    puts "  Start a 1 minute, 30 second timer:"
    puts "    timer 1:30"
    puts "  Start a 25 minute timer with a label:"
    puts "    timer 25 'Pomodoro'"
    puts "  Start a 1 hour, 30 minute, 45 second timer:"
    puts "    timer 1:30:45"
    exit
  end

  def start(time_string, label=nil)
    clear_terminal

    time_string = "#{NUM_MINUTES}:00" unless time_string&.length && time_string.length > 0
    num_seconds = time_to_seconds(time_string)
    target = Time.at(Time.now + num_seconds).to_i

    title = [
      label,
      "timer for",
      seconds_to_verbose(num_seconds)
    ].compact.join(" ")

    puts title
    puts "Timer up at #{Time.at(target).strftime("%I:%M %p")}"
    puts "Press Ctrl-C to stop the timer.\n"

    go(num_seconds)

    alert "Your #{title} is up."

  end

  private

  def overwrite(str)
    puts OVERWRITE_LINE + str
  end

  def pad(str)
    str.to_s.rjust(2, "0")
  end

  ENVIRONMENTS = {
    linux: 0,
    mac: 1,
    windows: 2
  }

  def os
    @_os ||= if `which osascript` && $?.success?
      ENVIRONMENTS[:mac]
    elsif `which spd-say` && $?.success?
      ENVIRONMENTS[:linux]
    elsif `which espeak` && $?.success?
      ENVIRONMENTS[:windows]
    end
  end

  def mac?
    os == ENVIRONMENTS[:mac]
  end

  def clear_terminal
    if mac?
      `osascript -e 'if application "Terminal" is frontmost then tell application "System Events" to keystroke "k" using command down'`
    else
      `clear -x`
    end
  end

  def alert(message="")
    threads = []
    if `which say` && $?.success?
      threads << Thread.new { `say "#{message}"` }
      threads << Thread.new { `osascript -e 'display alert "#{message}"'` }
    else
      threads << Thread.new { "spd-say #{message}" }
    end
    threads.each(&:join)
  end

  def time_to_seconds(time_string)
    time_string += ":00" unless time_string.include?(":")
    time_string.split(":").map(&:to_i).inject(0) { |sum, n| sum * 60 + n }
  end

  def bucket_seconds(seconds)
    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    seconds = seconds % 60
    { hour: hours, minute: minutes, second: seconds }
  end

  def seconds_to_timestring(seconds)
    bucket_seconds(seconds).values.map { |n| n.to_s.rjust(2, "0") }.join(":")
  end

  def seconds_to_verbose(seconds)
    bucket_seconds(seconds).map do |k, n|
      n.to_s + " " + k.to_s + (n == 1 ? "" : "s") if n > 0
    end.compact.join(", ")
  end

  def go(num_seconds)
    target = Time.at(Time.now + num_seconds).to_i
    loop do
      togo = target - Time.now.to_i
      minutes = (togo / 60).floor
      seconds = (togo % 60)
      break if togo < 0 # Time's up!

      render_timer(togo, num_seconds)
      sleep 1
    end
  end

  def timer_bar(percentage)
    bar = (BLOCK * percentage)
    if percentage > THRESHOLD_YELLOW
      bar.light_green
    elsif percentage > THRESHOLD_RED
      bar.light_yellow
    else
      bar.light_red
    end
  end

  def render_timer(remaining, total)
    percentage = ((remaining / total.to_f) * 100).floor
    timestamp = seconds_to_timestring(remaining).light_blue
    overwrite (timestamp + timer_bar(percentage))
  end
end

timer = Timer.new
timer.help if ARGV.length > 0 && ARGV.grep(/-h/).any?
timer.start ARGV[0], ARGV[1]
