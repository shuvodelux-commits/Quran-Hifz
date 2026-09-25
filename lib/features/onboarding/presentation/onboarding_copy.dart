import '../../settings/domain/app_preferences.dart';

const String? onboardingSupportEmail = null;

String developerHeading(AppLanguage language) => language == AppLanguage.bangla
    ? 'ডেভেলপারের পক্ষ থেকে'
    : 'From the developer';

String developerIntro(AppLanguage language) => language == AppLanguage.bangla
    ? 'আল কুরআন শুরু করার আগে একটি ছোট দোয়ার অনুরোধ ও গোপনীয়তার কথা।'
    : 'A short privacy note and a request for dua before you begin.';

String privacyMessage(AppLanguage language) => language == AppLanguage.bangla
    ? 'এই কুরআন অ্যাপটি সম্পূর্ণ বিজ্ঞাপনমুক্ত। ডেভেলপার এই অ্যাপের মাধ্যমে ব্যবহারকারীর ব্যক্তিগত তথ্য সংগ্রহ বা বিক্রি করেন না। অ্যাপের প্রয়োজনীয় তথ্য আপনার ডিভাইসেই সংরক্ষিত থাকে। লোকেশন সেটআপ এবং অনলাইন বা ডাউনলোডযোগ্য অডিও/কনটেন্ট ব্যবহারের মতো কিছু ফিচারে ইন্টারনেট প্রয়োজন হতে পারে।'
    : 'This Quran app is completely ad-free. The developer does not collect or sell users’ personal information through this app. App data needed for normal use is stored on your device. Some features, such as location setup and online or downloadable audio/content, may require internet access.';

String dedicationMessage(AppLanguage language) => language == AppLanguage.bangla
    ? 'এই অ্যাপটি ডেভেলপার তাঁর বাবা মরহুম জারজিস হোসেন প্রামাণিক-এর জন্য উৎসর্গ করেছেন।'
    : 'The developer dedicates this app to his late father, Jarjis Hossain Pramanik.';

String duaRequest(AppLanguage language) => language == AppLanguage.bangla
    ? 'সকলের কাছে বিনীত অনুরোধ—আমার বাবার মাগফিরাতের জন্য দোয়া করবেন। সম্ভব হলে আপনাদের সালাতে অন্তত একবার তাঁর জন্য দোয়া করবেন—এই আশা রাখছি।'
    : 'Please remember my father in your duas for forgiveness and mercy. If possible, I humbly ask that you make dua for him at least once in your salah.';

String supportIntro(AppLanguage language) => language == AppLanguage.bangla
    ? 'অ্যাপ ব্যবহারে কোনো সমস্যা, ভুল বা পরামর্শ থাকলে এই ইমেইলে জানাতে পারেন। ইনশাআল্লাহ, যথাসম্ভব সমাধানের চেষ্টা করব।'
    : 'If you find a problem, mistake, or have a suggestion, you can contact the support email below. In sha Allah, I will try to address it as far as possible.';
