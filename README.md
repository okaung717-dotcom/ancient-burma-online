# Ancient Burma Online Prototype — Mobile First

Godot 4.7+ အတွက် ဖန်တီးထားသော Android/iOS mobile-first starter prototype ဖြစ်ပါတယ်။ Final game art မဟုတ်သေးဘဲ ဖုန်း control၊ offline testing နဲ့ multiplayer foundation ကို အရင်တည်ဆောက်ထားတာပါ။

## အခုပါဝင်ပြီးသားအရာများ
- 3D third-person character controller
- ဘယ်ဘက် virtual joystick
- ညာဘက် screen swipe camera
- JUMP touch button
- USE / Interact touch button
- Responsive landscape mobile HUD
- Offline test mode
- ENet Host / Join multiplayer foundation
- Ancient Burmese-inspired placeholder costume
- Night palace courtyard placeholder environment
- စမ်းသပ်အသုံးပြုနိုင်သော ancient bell shrine

## Godot မှာဖွင့်နည်း
1. Folder ကို unzip လုပ်ပါ။
2. Godot Project Manager > Import ကိုနှိပ်ပါ။
3. `project.godot` ကိုရွေးပါ။
4. Import & Edit ကိုနှိပ်ပါ။
5. F6/F5 ဖြင့် run ပြီး `PLAY OFFLINE` ကိုနှိပ်ပါ။

## Mobile Controls
- ဘယ်ဘက် joystick — လမ်းလျှောက်/ပြေး
- ညာဘက် screen area ကိုဆွဲ — camera လှည့်
- JUMP — ခုန်
- USE — မျက်နှာမူထားသော အနီးဆုံး interactable object ကိုအသုံးပြု

Mac Godot Editor မှာစမ်းသပ်ရန် mouse ကို touch အဖြစ် emulate လုပ်ထားပါတယ်။ Keyboard controls က editor debug fallback သာဖြစ်ပြီး mobile HUD ကိုအစားမထိုးပါ။

## LAN Multiplayer စမ်းနည်း
1. Device/Computer A မှာ `HOST GAME` နှိပ်ပါ။
2. Device/Computer B မှာ A ရဲ့ local IP ကိုထည့်ပြီး `JOIN GAME` နှိပ်ပါ။
3. Firewall မှာ UDP port 7000 ကိုခွင့်ပြုရနိုင်ပါတယ်။

## Android Export
`docs/MOBILE_SETUP_MM.md` ကိုဖတ်ပြီး OpenJDK 17၊ Android SDK နဲ့ Godot Android export template ကိုပြင်ဆင်ပါ။ ပထမဆုံး APK ကို ကိုယ်ပိုင်ဖုန်းမှာစမ်းပြီး Play Store အတွက်နောက်မှ AAB ထုတ်ပါ။

## နောက် Milestones
1. Real character model + animations
2. Mobile graphics quality presets
3. Quest and inventory system
4. 2–4 player Internet room system
5. Login, saved outfits and player profile
6. Dedicated authoritative server

## သတိပြုရန်
လက်ရှိ character နဲ့ environment က placeholder ဖြစ်ပါတယ်။ Final realistic Ancient Burmese-inspired art assets၊ animation၊ quest၊ chat၊ authentication၊ database နဲ့ anti-cheat တို့ကို နောက် milestones တွင်ထည့်ရပါမယ်။
