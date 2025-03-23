# slothy-BusStops
A QBCore-based bus travel system allowing players to travel from Point A to Point B with ease. QB Checks for jobs and such and uses ox_inv. I will work on it soon to check from the getgo. 

## Features
- **Bus Travel**: Travel between configurable bus stops across cities and towns with calculated fares and trip durations.
- **LEO Passenger Tracking**: Law enforcement officers (LEO) can check active bus passengers, with dynamic job-based access.
- **Dynamic Notifications**: Players receive updates every 30 seconds during their trip with time remaining and destination.
- **Simple Integration**: Built for QBCore with `ox_target` and `ox_lib` for seamless interactions and menus.

## Installation
1. Download the latest version of `slothy-BusStops`.
2. Drag the folder into your `resources` directory.
3. Add `ensure slothy-BusStops` to your `server.cfg`.
4. Ensure dependencies (`qb-core`, `ox_target`, `ox_lib`) are installed and running.

## Configuration
The script is ready to use out-of-the-box, but you can customize it in `config.lua`:
- Add or modify bus stops in `Config.Locations` (supports cities with subdistricts and standalone towns).
- Adjust fare pricing (`Config.BusFare`) and LEO job permissions (`Config.LEOTracking.Departments`).
- Enable debug mode (`Config.Debug`) for troubleshooting.

Each bus stop defined in the config will automatically generate a target zone in-game.

## Script Showcase
Check out the script in action:  
[YouTube Showcase](https://www.youtube.com/watch?v=nzH93xqkE1A)

## Support
If you encounter issues, have suggestions, or need help, join my Discord:  
[Discord Invite](https://discord.gg/RQBhmWEzTx)

Enjoy the script, and let me know how it works for you!
