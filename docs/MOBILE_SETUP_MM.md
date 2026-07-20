# Mobile Build Setup — Myanmar Guide

## Project Direction
ဒီ project ကို landscape mobile game အဖြစ်ပြင်ထားပါတယ်။ Reference resolution က 1280×720 ဖြစ်ပြီး UI က screen ratio ပြောင်းလဲမှုကို anchors နဲ့လိုက်ညှိပေးပါတယ်။ Rendering method ကို Mobile အဖြစ်ထားပြီး FPS ကို 60 ကန့်သတ်ထားပါတယ်။

## Mac မှာ Android စမ်းရန်
1. Godot Export Templates ကို install လုပ်ပါ။
2. OpenJDK 17 ကို install လုပ်ပါ။
3. Android Studio နဲ့ Android SDK ကို install လုပ်ပါ။
4. Godot > Editor Settings > Export > Android ထဲမှာ Java SDK Path နဲ့ Android SDK Path ကိုထည့်ပါ။
5. Project > Export > Add Android preset ကိုရွေးပါ။
6. USB debugging ဖွင့်ထားသော Android ဖုန်းကို Mac နဲ့ချိတ်ပါ။
7. One-click deploy သို့မဟုတ် debug APK export လုပ်ပြီး စမ်းပါ။

## Gameplay Test Checklist
- PLAY OFFLINE နှိပ်ပြီး menu ပျောက်သွားခြင်း
- Left joystick နဲ့ player ရွေ့ခြင်း
- Right screen swipe နဲ့ camera လှည့်ခြင်း
- JUMP button အလုပ်လုပ်ခြင်း
- Ancient bell ကိုမျက်နှာမူပြီး USE နှိပ်လျှင် message ပြခြင်း
- 16:9 နဲ့ wider screen များမှာ buttons မကွက်ထွက်ခြင်း

## Performance Target
- Mid-range Android: 30–60 FPS
- Character texture: ပုံမှန်အားဖြင့် 1K–2K
- Real-time shadow: main directional light အဓိကတစ်ခု
- Transparent effects နဲ့ dynamic lights ကို ကန့်သတ်အသုံးပြုရန်
- Final assets အတွက် LOD levels ထည့်ရန်
