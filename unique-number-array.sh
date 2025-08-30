#!/bin/bash
############### Random Unique Number Generator
### SaunDev ### Play Lotto, ThunderBall, EuroMillions, PowerBall, etc.
############### Best of Luck! 
### Uses jot cli tool on MacOS / BSD. For Linux, use shuf or seq (Note TODO)
### To play, run script with game profile or custom parameters:
### ./unique-number-array.sh [lotto|euromillions|megamillions|powerball|superenalotto|thunderball|hotpicks|eurohotpicks] [ball_count] [bonus_ball_count] [ball_limit] [bonus_ball_limit]
### Examples:
### . ./unique-number-array.sh
### . ./unique-number-array.sh lotto
### . ./unique-number-array.sh custom 5 2 47 9
### Please note that bash is quite janky and if this was python I would be checking each numbers uniqueness -
### - instead of spamming command - Maybe I need to contribute to jot.
### [START] Select Your Game Profile Number Map!
declare -A games
games[euromillions]="5 2 50 12"
games[eurohotpicks]="5 0 50 0"
games[hotpicks]="7 0 49 0"
games[lotto]="6 0 59 0"
games[megamillions]="5 1 70 25"
games[powerball]="5 1 69 26"
games[superenalotto]="6 0 90 0"
games[thunderball]="5 1 39 14"
games[custom]="${2:-6} ${3:-0} ${4:-59} ${5:-0}"
# Custom profile with optional parameters - Which defaults to Lotto if no profile or parameters provided

profile=${1:-lotto}
if [[ -n "${games[$profile]}" ]]; then
  read ball_count bb_count ball_max bb_max <<< "${games[$profile]}"
else
  echo "Unknown game profile: $profile"
  echo "Available Games: lotto|euromillions|megamillions|powerball|superenalotto|thunderball|hotpicks|eurohotpicks"
  return 1 2>/dev/null || exit 1
fi

# Set ball counts and ranges from profile or custom parameters
ball_count=${ball_count:-${2:-6}}
bb_count=${bb_count:-${3:-0}}

ball_min=1
ball_max=${ball_max:-${4:-59}}
bb_max=${bb_max:-${5:-14}}

if [[ $ball_count -gt $ball_max ]]; then
  echo "Error: Number of balls ($ball_count) cannot be greater than the range ($ball_max)."
  return 1 2>/dev/null || exit 1
fi

while :; do
  luck_numbers=($(jot -r $ball_count $ball_min $ball_max | sort -n))
  unique_count=$(printf "%s\n" "${luck_numbers[@]}" | sort -u | wc -l)
  if [[ $unique_count -eq $ball_count ]]; then
    break
  fi
done

if [[ $bb_count -gt 0 ]]; then
  if [[ $bb_count -gt $bb_max ]]; then
    echo "Error: Number of bonus balls ($bb_count) cannot be greater than the range ($bb_max)."
    return 1 2>/dev/null || exit 1
  fi
  while :; do
    bonus_numbers=($(jot -r $bb_count $ball_min $bb_max | sort -n))
    unique_bb_count=$(printf "%s\n" "${bonus_numbers[@]}" | sort -u | wc -l)
    if [[ $unique_bb_count -eq $bb_count ]]; then
      break
    fi
  done
  numbers+=("${bonus_numbers[@]}")
fi

if [[ -z "$1" ]]; then
  game_name="Custom"
else
  game_name="$(tr '[:lower:]' '[:upper:]' <<< "${1:0:1}")${1:1}"
fi

if [[ $bb_count -gt 0 ]]; then
  printf 'Your %s Numbers: %s + Bonus Ball(s): %s\n' "$game_name" "$(IFS=,; echo "${luck_numbers[*]}")" "$(IFS=,; echo "${bonus_numbers[*]}")"
  else
    printf 'Your %s Numbers: %s\n' "$game_name" "$(IFS=,; echo "${luck_numbers[*]}")"
fi
