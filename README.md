# Meatball BB-8
This was a quick hack I did for an Oscars party in 2016 where guests where asked to bring a dish based on a nominated film. *Star Wars: The Force Awakens* had five nominations, so I decided to make meatball-based BB-8s.

While waiting for the food to cook, I also decided to rig the lid of the serving dish so that it would make BB-8 sound effects whenever it was moved.

## Food Recipe
This recipe is based on an [easy slow-cooker meatball recipe](http://www.iheartnaptime.net/bbq-meatballs/) I found online.

### Ingredients

* 18oz grape jelly
* 18oz BBQ sauce
* 24 large fully-cooked frozen meatballs
* 12 small fully-cooked frozen meatballs
* Toothpicks

### Directions

1. Combine the grape jelly and BBQ sauce in a slow cooker. Mix well.
2. Add the meatballs to the slow cooker and stir until all the meatballs are covered in sauce.
3. Cook on High for 3 hours.
4. Cut the small meatballs in half into semispheres. These will be BB-8's head.
5. Place the heads on top of the larger meatballs and secure with a toothpick. The larger meatballs form BB-8's body.
6. Pour a layer of the sauce onto the base of the serving tray and place the meatball BB-8s onto the tray.

Ideally, you will use a tray with a lid. I used a plastic tray with a lightweight plastic lid.

## Rigging the Lid
I used a first-generation [Pebble smartwatch](https://www.pebble.com/pebble-smartwatch-features) as the sensor device on the lid, since I had one lying around.

### App
I wrote a quick and dirty app to that used the Pebble's onboard accelerometer to detect movement. Once the movement exceeded a certain threshold, the Pebble sends a Bluetooth command to an iOS app.

The source code for the Pebble app can be found in `Pebble/`.

### Attaching to Lid
I placed the Pebble in a Ziploc bag to prevent sauce from dripping on it and taped the bag to the top of the lid.

**Note:** You'll probably also want to disable notifications on the Pebble itself, which you can do under Settings -> Notifications -> Filter -> Mute All.

## iPhone
I used an old iPhone to play the BB-8 sound effects when the lid moved. To do this, I wrote an iOS app that used the [Pebble SDK](https://developer.pebble.com/guides/mobile-apps/ios/) to receive commands from the BB-8 Pebble app.

When the app received a command from the Pebble app, it would clear any existing app notifications (to prevent the lock screen from filling up with notifications) and schedule a local notification with a BB-8 sound effect for 300ms later (necessary to prevent the notification-clearing code from canceling the new notification).

The source code for the iOS app can be found in `iOS/`, however this does not include the BB-8 sound effects as they are copyrighted. Find five of your own sound files, convert them to AIFF, and save them in `iOS/BB-8/` as `bb8_01.aif` to `bb8_05.aif`.

The notifications/sound effects only play when the app is in the background.
