#!ruby

require 'colorize'

NUM_MINUTES = 25
OVERWRITE_LINE = "\e[1A\e[K"

BLOCK = "█"
BLOCK_CHARS = "▎▍▌▋▊▉"
THRESHOLD_YELLOW = 50 # Percentage of time remaining at which to turn timer yellow
THRESHOLD_RED = 20 # Percentage of time remaining at which to turn timer red
TIMES_UP_SPOKEN="Hey Pommo-Dorko, your time is up"
TIMES_UP_ALERT_TITLE="Pomodorko"
TIMES_UP_ALERT_BODY="Time is up. Switch tasks?"

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
    # threads << Thread.new { `say "Your #{num_minutes} minute #{title} timer is up."` }
    # threads << Thread.new { `osascript -e 'display alert "#{TIMES_UP_ALERT_TITLE}" message "#{TIMES_UP_ALERT_BODY}" as critical'` }
    threads << Thread.new { `say "#{message}"` }
    threads << Thread.new { `osascript -e 'display alert "#{message}'` }
  else
    threads << Thread.new { "spd-say #{message}" }
  end
  threads.each(&:join)
end

def go(num_minutes, title="")
  clear_terminal
  puts "Number of minutes: #{num_minutes}"
  puts "Title: #{title}"

  num_minutes ||= NUM_MINUTES
  num_minutes = num_minutes.to_i
  num_seconds = num_minutes * 60
  target = Time.at(Time.now + num_seconds).to_i

  loop do
    togo = target - Time.now.to_i
    minutes = (togo / 60).floor
    seconds = (togo % 60)
    break if minutes < 0 # Time's up!

    percentage = ((togo / num_seconds.to_f) * 100).floor
    char_num = ((seconds / 60.0) * BLOCK_CHARS.length).floor
    if percentage > THRESHOLD_YELLOW
      overwrite "#{pad(minutes)}:#{pad(seconds)}".light_blue + " " + "#{BLOCK * minutes}".light_green + BLOCK_CHARS[char_num].light_green
    elsif percentage > THRESHOLD_RED
      overwrite "#{pad(minutes)}:#{pad(seconds)}".light_blue + " " + "#{BLOCK * minutes}".light_yellow + BLOCK_CHARS[char_num].light_yellow
    else
      overwrite "#{pad(minutes)}:#{pad(seconds)}".light_blue + " " + "#{BLOCK * minutes}".light_red + BLOCK_CHARS[char_num].light_red
    end
    sleep 1
  end

  alert "Your #{num_minutes} minute #{title} timer is up."

end

go ARGV[0], ARGV[1]
