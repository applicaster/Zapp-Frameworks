# Copa America Stats Change Log

All notable changes to this project will be documented in this file.

## 0.2.22
- Applying default names in match items to avoid recycling issues.
- Fix dates comparison when getting the matches to show in the home carousel.

## 0.2.21
- Fixes to recycling of images in all matches screen

## 0.2.20
- Changing the size of page indicator to allow for more items on team screen
- Changing PENALTIS to PENALES in spanish localization
- Fixing NULL score on matches that went to penalties
    - This was due to the fact we check for Extra Time Score and Copa America doesnt go to Extra Time. We now check Extra time first if its null then we use Final Time.

## 0.2.19
- Changing the size of page indicator to allow for more items

## 0.2.18
- Adding param that allows to control how many matches are loaded in the main carousel of the home screen

## 0.2.17
- Fix of Date Of Birth of the player in Player Details screen.
- Added city of birth to the player in Player Details screen.
- Translations for the aggregation panel headers in Group card.
- Doing heartbeat only for match cards in the Home screen.
- Capitalizing the type of the non-players members (like Coach, etc).
- Avoiding the home view will not change when heartbeating.
- Making the player list in team screen more friendly for small screens.

## 0.2.16
- Small bug fix that was causing the date to change to the next day

## 0.2.15
- Small bug fix of view visibility

## 0.2.14
- Adding more info button
- Fixing next match logic on home screen
- Fixing players sorting and coaches / assistants
- Fixing bug in score tables

## 0.2.13
- Images of the t-shirts of the teams were reduced, improving the loading of the team screen details.
- Improve compatibility of Team Screen, by changing the format of the size of the t-shirt numbers.
- Added heartbeat to the home screen.
- When the first goal is nulled, the list of goals in Match Details screen will update to an empty list of goals.

## 0.2.12
- Improved Player details screen design.

## 0.2.11
- Changed some old shields for new ones.

## 0.2.10
- Changed Paraguay shield for a new one.

## 0.2.9
- Fix in one of the stats of the Player (goals in the current torunament).

## 0.2.8
- Improvement of the design of the Player Details screen.

## 0.2.7
- Added localizations for Game Status and Player Positions.

## 0.2.6
- Forcing the screen orientation to be portrait.
- Improved the way penalties are shown.
- This version includes some bug fixes.

## 0.2.5
- Showing Penalties indicator when the match is/was in Penalties stage.
- Loading navigation assets (logo in the toolbar and back button image) from zapp.
- Showing as first match the first one of the current day in All Matches screen.

## 0.2.4
- Fixes on Match Details screen.
- Some UI changes to make both OS more consistent.
- Now the user will know when the match is in Half time.

## 0.2.3
- Match details screen is updating each minute.

## 0.2.2
- Cache enabled to see info already downloaded when device is offline.

## 0.2.1
- Clicking in Match item in Team Screen will take you to the Match Details screen.
- Clicking in any flag will take you to the correspondent Team screen.
- Added Ubuntu font for text using it in the original design.